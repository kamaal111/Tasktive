//
//  TasksViewModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import Logster
import PopperUp
import CloudKit
import Environment
import SharedModels
import TasktiveLocale
import ShrimpExtensions

private let logger = Logster(from: TasksViewModel.self)

final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [Date: [AppTask]] = [:]
    @Published private(set) var loadingTasks = false
    @Published private(set) var settingTasks = false
    @Published private(set) var pendingUserError: UserErrors?

    private let backend: Backend
    private let notifications: [Notification.Name] = [
        .iCloudChanges,
    ]

    init() {
        #if !DEBUG
        self.backend = .init()
        #else
        self.backend = .init(preview: Environment.CommandLineArguments.previewCoredata.enabled)
        #endif

        setupObservers()
    }

    #if DEBUG
    init(preview: Bool) {
        self.backend = .init(preview: preview || Environment.CommandLineArguments.previewCoredata.enabled)

        setupObservers()
    }
    #endif

    deinit {
        removeObservers()
    }

    var taskDates: [Date] {
        tasks
            .keys
            .sorted(by: {
                $0.compare($1) == .orderedAscending
            })
    }

    var allTasksSortedByCreationDate: [AppTask] {
        tasks
            .values
            .flatMap { $0 }
            .sorted(by: \.creationDate, using: .orderedAscending)
    }

    func setTickOnTask(_ task: AppTask, with newTickedState: Bool) async -> Result<Void, UserErrors> {
        await updateTask(task, with: task.toggleCoreTaskTickArguments(with: newTickedState))
    }

    func tasksForDate(_ date: Date) -> [AppTask] {
        let startDate = getHashDate(from: date)
        return tasks[startDate] ?? []
    }

    func progressForDate(_ date: Date) -> Double {
        let tasks = tasksForDate(date)

        guard !tasks.isEmpty else { return 0 }

        let tasksDone = tasks
            .reduce(0) { result, task in
                if task.ticked {
                    return result + 1
                }
                return result
            }
        return Double(tasksDone) / Double(tasks.count)
    }

    func createTask(with arguments: TaskArguments, on source: DataSource) async -> Result<Void, UserErrors> {
        let createTaskResult = await backend.tasks.create(with: arguments, on: source)
        switch createTaskResult {
        case let .failure(failure):
            let maybeMappedBackendError = await mapBackendTaskErrors(failure)
            return .failure(maybeMappedBackendError ?? .createTaskFailure)
        case .success:
            break
        }

        return await refreshTasks()
    }

    func getInitialTasks(from sources: [DataSource]) async -> Result<Void, UserErrors> {
        await _getTasks(from: sources, for: Date(), dataIsStale: false, updateNotCompletedTasks: true)
    }

    func getTasks(from sources: [DataSource], for date: Date) async -> Result<Void, UserErrors> {
        await _getTasks(from: sources, for: date, dataIsStale: false, updateNotCompletedTasks: false)
    }

    #if DEBUG
    /// Fetches all tasks and stores them in the ``tasks`` property.
    /// This method is only to be used in the playground screens, that's why it's under a `DEBUG` flag.
    /// - Parameter sources: The specific datasources to fetch from.
    /// - Returns: A result which is either `Void` on success or ``UserErrors`` on failure.
    func getAllTasks(from sources: [DataSource]) async -> Result<Void, UserErrors> {
        let (tasks, error) = await backend.tasks.list(
            from: sources,
            updateNotCompleted: false,
            forceFetch: false
        )
        if let tasks {
            let groupedTasks = Dictionary(grouping: tasks, by: {
                getHashDate(from: $0.dueDate)
            })
            for (date, tasks) in groupedTasks {
                await setTasks(tasks, forDate: date)
            }
        }

        if let error {
            let mappedError = await mapBackendTaskErrors(error)
            return .failure(mappedError ?? .getAllFailure)
        }

        return .success(())
    }
    #endif

    func updateTask(_ task: AppTask, with arguments: TaskArguments) async -> Result<Void, UserErrors> {
        await withSettingTasks(completion: {
            guard task.arguments != arguments else { return .success(()) }

            let validationResult = validateTaskArguments(arguments)
            switch validationResult {
            case let .failure(failure):
                return .failure(failure)
            case .success:
                break
            }

            let taskID = task.id

            let oldDateHash = getHashDate(from: task.dueDate)
            guard let taskIndex = tasks[oldDateHash]?.findIndex(by: \.id, is: taskID)
            else { return .failure(.updateFailure) }

            let updateTaskResult = await backend.tasks.update(on: task.source, by: taskID, with: arguments)
            let updatedTask: AppTask
            switch updateTaskResult {
            case let .failure(failure):
                let maybeBackendError = await mapBackendTaskErrors(failure)
                return .failure(maybeBackendError ?? .updateFailure)
            case let .success(success):
                updatedTask = success
            }

            var mutableTask = tasks

            let newDateHash = getHashDate(from: arguments.dueDate)
            if oldDateHash != newDateHash {
                mutableTask[newDateHash]?.append(updatedTask)
                mutableTask[oldDateHash]?.remove(at: taskIndex)

                await setTasks(mutableTask[newDateHash] ?? [updatedTask], forDate: newDateHash)
            } else {
                mutableTask[oldDateHash]?[taskIndex] = updatedTask
            }

            await setTasks(mutableTask[oldDateHash] ?? [], forDate: oldDateHash)

            return .success(())
        })
    }

    func deleteTask(_ task: AppTask) async -> Result<Void, UserErrors> {
        await withSettingTasks(completion: {
            let deleteTaskResult = await backend.tasks.delete(on: task.source, by: task.id)
            switch deleteTaskResult {
            case let .failure(failure):
                let maybeBackendError = await mapBackendTaskErrors(failure)
                return .failure(maybeBackendError ?? .deleteFailure)
            case .success:
                break
            }

            let dateHash = getHashDate(from: task.dueDate)
            guard let taskIndex = tasks[dateHash]?.findIndex(by: \.id, is: task.id) else {
                return .failure(.deleteFailure)
            }

            var mutableTask = tasks
            mutableTask[dateHash]?.remove(at: taskIndex)
            await setTasks(mutableTask[dateHash] ?? [], forDate: dateHash)

            return .success(())
        })
    }

    private func refreshTasks() async -> Result<Void, UserErrors> {
        guard let lastFetchedContext = await backend.tasks.getLastFetchedForContext() else { return .success(()) }

        return await getTasks(from: lastFetchedContext.sources, for: lastFetchedContext.date)
    }

    @discardableResult
    private func _getTasks(from sources: [DataSource],
                           for date: Date,
                           dataIsStale: Bool,
                           updateNotCompletedTasks: Bool) async -> Result<Void, UserErrors> {
        await withLoadingTasks {
            let (tasks, error) = await backend.tasks.filter(
                from: sources,
                for: date,
                updateNotCompleted: updateNotCompletedTasks,
                forceFetch: dataIsStale
            )
            if let tasks {
                await setTasks(tasks, forDate: date)
            }

            if let error {
                let mappedError = await mapBackendTaskErrors(error)
                return .failure(mappedError ?? .getAllFailure)
            }

            return .success(())
        }
    }

    @MainActor
    func setPendingUserError(_ error: UserErrors?) {
        pendingUserError = error
    }

    private func mapBackendTaskErrors(_ error: TasksClient.Errors) async -> UserErrors? {
        switch error {
        case .saveFailure:
            logger.error(label: "failed to create task", error: error)
            return .createTaskFailure
        case .fetchFailure:
            logger.error(label: "failed to fetch tasks", error: error)
            return .getAllFailure
        case .updateFailure:
            logger.error(label: "failed to update tasks", error: error)
            return .updateFailure
        case .deleteFailure:
            logger.error(label: "failed to delete tasks", error: error)
            return .deleteFailure
        case .updateManyFailure:
            logger.error(label: "failed to update many tasks", error: error)
            return .updateFailure
        case .clearFailure:
            logger.error(label: "failed to clear tasks", error: error)
            return .none
        case .notFound:
            logger.error(label: "failed to find task", error: error)
            return .getAllFailure
        case .generalFailure:
            logger.error(label: "general task error", error: error)
            return .none
        case .iCloudDisabledByUser:
            logger.warning("iCloud has been disbaled by user")
            await setPendingUserError(.iCloudIsDisabled)
            return .iCloudIsDisabled
        }
    }

    private func validateTaskArguments(_ arguments: TaskArguments) -> Result<Void, UserErrors> {
        guard !arguments.title.trimmingByWhitespacesAndNewLines.isEmpty else { return .failure(.invalidTitle) }

        return .success(())
    }

    private func withLoadingTasks<T>(completion: () async -> T) async -> T {
        await setLoadingTasks(true)
        let result = await completion()
        await setLoadingTasks(false)
        return result
    }

    private func withSettingTasks<T>(completion: () async -> T) async -> T {
        await setSettingTasks(true)
        let result = await completion()
        await setSettingTasks(false)
        return result
    }

    @MainActor
    private func setSettingTasks(_ state: Bool) {
        guard settingTasks != state else { return }
        settingTasks = state
    }

    @MainActor
    private func setLoadingTasks(_ state: Bool) {
        guard loadingTasks != state else { return }
        loadingTasks = state
    }

    private func getHashDate(from date: Date) -> Date {
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: date)
        return Calendar.current.date(from: dateComponents) ?? Date()
    }

    @MainActor
    private func setTasks(_ tasks: [AppTask], forDate date: Date) {
        self.tasks[getHashDate(from: date)] = tasks
    }

    private func setupObservers() {
        notifications.forEach { notification in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNotification),
                name: notification,
                object: .none
            )
        }
    }

    private func removeObservers() {
        notifications.forEach { notification in
            NotificationCenter.default.removeObserver(self, name: notification, object: .none)
        }
    }

    @objc
    private func handleNotification(_ notification: Notification) {
        switch notification.name {
        case .iCloudChanges:
            let notificationObject = notification.object as? CKNotification
            logger.info("recieved iCloud changes notification; \(notificationObject as Any)")
            guard Environment.Features.iCloudSyncing, UserDefaults.iCloudSyncingIsEnabled ?? true else { return }

            Task {
                guard let lastFetchedContext = await backend.tasks.getLastFetchedForContext() else { return }

                let dataSources = lastFetchedContext.sources
                    .appended(.iCloud)
                    .uniques()

                await _getTasks(from: dataSources,
                                for: lastFetchedContext.date,
                                dataIsStale: true,
                                updateNotCompletedTasks: false)
            }
        default:
            break
        }
    }
}

extension TasksViewModel {
    enum UserErrors: PopUpError, Error {
        case getAllFailure
        case createTaskFailure
        case updateFailure
        case deleteFailure
        case invalidTitle
        case iCloudIsDisabled

        var title: String {
            switch self {
            case .getAllFailure:
                return TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE)
            case .createTaskFailure:
                return TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE)
            case .updateFailure:
                return TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE)
            case .deleteFailure:
                return TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE)
            case .invalidTitle:
                return TasktiveLocale.getText(.GENERAL_WARNING_TITLE)
            case .iCloudIsDisabled:
                return TasktiveLocale.getText(.ICLOUD_DISABLED_WARNING_TITLE)
            }
        }

        var errorDescription: String {
            switch self {
            case .getAllFailure:
                return TasktiveLocale.getText(.GET_ALL_TASKS_ERROR_DESCRIPTION)
            case .createTaskFailure:
                return TasktiveLocale.getText(.CREATE_TASK_ERROR_DESCRIPTION)
            case .updateFailure:
                return TasktiveLocale.getText(.UPDATE_TASK_ERROR_DESCRIPTION)
            case .deleteFailure:
                return TasktiveLocale.getText(.DELETE_TASK_ERROR_DESCRIPTION)
            case .invalidTitle:
                return TasktiveLocale.getText(.INVALID_TITLE_WARNING_DESCRIPTION)
            case .iCloudIsDisabled:
                return TasktiveLocale.getText(.ICLOUD_DISABLED_WARNING_DESCRIPTION)
            }
        }

        var popupType: PopperUpBottomType {
            switch self {
            case .getAllFailure, .createTaskFailure, .updateFailure, .deleteFailure:
                return .error
            case .invalidTitle, .iCloudIsDisabled:
                return .warning
            }
        }

        var style: PopperUpStyles {
            .bottom(
                title: title,
                type: popupType,
                description: errorDescription
            )
        }

        var timeout: TimeInterval? {
            5
        }
    }
}
