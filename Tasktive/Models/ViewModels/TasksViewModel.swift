//
//  TasksViewModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import Skypiea
import PopperUp
import Environment
import TasktiveLocale
import ShrimpExtensions

private let logger = Logster(from: TasksViewModel.self)

struct TasksFetchedContext: Hashable, Equatable {
    let date: Date
    let dataSources: [DataSource]
}

final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [Date: [AppTask]] = [:]
    @Published private(set) var loadingTasks = false
    @Published private(set) var settingTasks = false
    @Published private(set) var pendingUserError: UserErrors?

    private var fetchedContexts: [TasksFetchedContext] = []
    private let dataClient: DataClient
    private let notifications: [Notification.Name] = [
        .iCloudChanges,
    ]

    init() {
        #if !DEBUG
        self.dataClient = .init()
        #else
        self.dataClient = .init(preview: Environment.CommandLineArguments.previewCoredata.enabled)
        #endif

        setupObservers()
    }

    #if DEBUG
    init(preview: Bool) {
        self.dataClient = .init(preview: preview || Environment.CommandLineArguments.previewCoredata.enabled)

        setupObservers()
    }
    #endif

    deinit {
        removeObservers()
    }

    var taskDates: [Date] {
        tasks.keys
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
        let task: AppTask
        do {
            task = try await dataClient.tasks.create(on: source, with: arguments)
        } catch {
            return .failure(.createTaskFailure)
        }

        var updatedTasks = tasks
        let hashDate = getHashDate(from: task.dueDate)
        if updatedTasks[hashDate] == nil {
            updatedTasks[hashDate] = [task]
        } else {
            updatedTasks[hashDate] = (updatedTasks[hashDate] ?? []) + [task]
        }

        await setTasks(updatedTasks[hashDate] ?? [], forDate: hashDate)

        return .success(())
    }

    func getTasks(from sources: [DataSource], for date: Date) async -> Result<Void, UserErrors> {
        await getTasks(from: sources, for: date, dataIsStale: false, updateNotCompletedTasks: false)
    }

    #if DEBUG
    /// Fetches all tasks and stores them in the ``tasks`` property.
    /// This method is only to be used in the playground screens, that's why it's under a `DEBUG` flag.
    /// - Parameter sources: The specific datasources to fetch from.
    /// - Returns: A result which is either `Void` on success or ``UserErrors`` on failure.
    func getAllTasks(from sources: [DataSource]) async -> Result<Void, UserErrors> {
        await getTasksByPredicate(from: sources, by: nil, updateNotCompletedTasks: false)
    }
    #endif

    func updateTask(_ task: AppTask, with arguments: TaskArguments) async -> Result<Void, UserErrors> {
        await withSettingTasks(completion: {
            guard task.coreTaskArguments != arguments else { return .success(()) }

            let validationResult = validateTaskArguments(arguments)
            switch validationResult {
            case let .failure(failure):
                return .failure(failure)
            case .success:
                break
            }

            let dateHash = getHashDate(from: task.dueDate)
            guard let taskIndex = tasks[dateHash]?.findIndex(by: \.id, is: task.id)
            else { return .failure(.updateFailure) }

            let updatedTask: AppTask
            do {
                updatedTask = try await dataClient.tasks.update(on: task.source, by: task.id, with: arguments)
            } catch {
                logger.error(label: "failed to update this task", error: error)
                return .failure(.updateFailure)
            }

            var mutableTask = tasks
            mutableTask[dateHash]?[taskIndex] = updatedTask
            await setTasks(mutableTask[dateHash] ?? [], forDate: dateHash)

            return .success(())
        })
    }

    func deleteTask(_ task: AppTask) async -> Result<Void, UserErrors> {
        await withSettingTasks(completion: {
            do {
                try await dataClient.tasks.delete(on: task.source, by: task.id)
            } catch {
                logger.error(label: "failed to delete this task", error: error)
                return .failure(.deleteFailure)
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

    private var lastFetchedContext: TasksFetchedContext? {
        fetchedContexts.last
    }

    private func shouldFetchTasks(newContext: TasksFetchedContext, dataIsStale: Bool) -> Bool {
        var fetchedContexts = fetchedContexts

        if dataIsStale {
            self.fetchedContexts = fetchedContexts.appended(newContext)

            return true
        }

        if let fetchedContextIndexWithSameDate = fetchedContexts.findIndex(by: \.date, is: newContext.date) {
            let fetchedContextWithSameDate = fetchedContexts[fetchedContextIndexWithSameDate]

            if fetchedContextWithSameDate.dataSources != newContext.dataSources {
                fetchedContexts.remove(at: fetchedContextIndexWithSameDate)
            }
        }

        if fetchedContexts.contains(newContext) {
            self.fetchedContexts = fetchedContexts

            return false
        }

        self.fetchedContexts = fetchedContexts.appended(newContext)

        return true
    }

    private func getTasks(from sources: [DataSource],
                          for date: Date,
                          dataIsStale: Bool,
                          updateNotCompletedTasks: Bool) async -> Result<Void, UserErrors> {
        let startDate = getHashDate(from: date)
        let newLastFetchedContext = TasksFetchedContext(date: startDate, dataSources: sources)

        guard shouldFetchTasks(newContext: newLastFetchedContext, dataIsStale: dataIsStale) else { return .success(()) }

        logger.info("fetching tasks for \(startDate)")

        let endDate = getHashDate(from: startDate.incrementByDays(1)).incrementBySeconds(-1)

        let predicate = NSPredicate(format: "(dueDate >= %@) AND (dueDate <= %@)", startDate.asNSDate, endDate.asNSDate)
        return await getTasksByPredicate(
            from: sources,
            by: predicate.predicateFormat,
            updateNotCompletedTasks: updateNotCompletedTasks
        )
    }

    private func getTasksByPredicate(from sources: [DataSource],
                                     by queryString: String?,
                                     updateNotCompletedTasks: Bool) async -> Result<Void, UserErrors> {
        await withLoadingTasks {
            var appTasks: [AppTask] = []

            var maybeError: UserErrors?
            for source in sources {
                let tasksResult = await getFilteredTasks(from: source, by: queryString)

                switch tasksResult {
                case let .failure(failure):
                    maybeError = failure
                case let .success(success):
                    appTasks.append(contentsOf: success)
                }
            }

            let maybeUpdatedTasks = await updateDueDateOfTasksIfNeeded(
                appTasks,
                enabled: updateNotCompletedTasks,
                sources: sources
            )

            let groupedTasks = Dictionary(grouping: maybeUpdatedTasks, by: {
                getHashDate(from: $0.dueDate)
            })

            for (date, tasks) in groupedTasks {
                if let previouslyFetchedTasks = self.tasks[date] {
                    let tasks: [AppTask] = tasks
                        .concat(previouslyFetchedTasks)
                        .reduce([]) { result, task in
                            if !result.contains(where: { $0.id == task.id }) {
                                return result.appended(task)
                            }
                            return result
                        }
                    await setTasks(tasks, forDate: date)
                } else {
                    await setTasks(tasks, forDate: date)
                }
            }

            if let error = maybeError {
                _ = fetchedContexts.popLast()
                return .failure(error)
            }

            return .success(())
        }
    }

    private func getFilteredTasks(from source: DataSource,
                                  by queryString: String?) async -> Result<[AppTask], TasksViewModel.UserErrors> {
        let tasks: [AppTask]
        do {
            tasks = try await dataClient.tasks.filter(from: source, by: queryString)
        } catch {
            logger.error(label: "failed to get all tasks", error: error)

            let maybeError = await handleCloudTaskErrors(error)

            _ = fetchedContexts.popLast()
            return .failure(maybeError ?? .getAllFailure)
        }

        return .success(tasks)
    }

    @MainActor
    func setPendingUserError(_ error: UserErrors?) {
        pendingUserError = error
    }

    private func handleCloudTaskErrors(_ error: Error) async -> UserErrors? {
        if let cloudErrors = error as? CloudTask.CrudErrors {
            switch cloudErrors {
            case let .fetchFailure(contextError):
                if let cloudableError = contextError as? CloudableErrors {
                    switch cloudableError {
                    case .iCloudDisabledByUser:
                        logger.warning("iCloud has been disabled by the user")
                        await setPendingUserError(.iCloudIsDisabled)
                        return .iCloudIsDisabled
                    }
                }
            default:
                break
            }
        }

        return .none
    }

    private func validateTaskArguments(_ arguments: TaskArguments) -> Result<Void, UserErrors> {
        guard !arguments.title.trimmingByWhitespacesAndNewLines.isEmpty else { return .failure(.invalidTitle) }

        return .success(())
    }

    private func updateDueDateOfTasksIfNeeded(_ tasks: [AppTask],
                                              enabled: Bool,
                                              sources: [DataSource]) async -> [AppTask] {
        guard enabled else { return tasks }

        let now = Date()
        let today = getHashDate(from: now).asNSDate
        let tasksIDs = tasks.map(\.id.nsString)
        let predicate = NSPredicate(format: "(dueDate < %@) AND ticked == NO AND NOT(id in %@)", today, tasksIDs)

        var updatedTasks: [AppTask] = []
        for source in sources {
            guard let outdatedTasks = try? await dataClient.tasks.filter(from: source, by: predicate.predicateFormat),
                  !outdatedTasks.isEmpty else { continue }

            do {
                try await dataClient.tasks.updateManyDates(outdatedTasks, from: source, date: now)
            } catch {
                logger.error(label: "failed to updated outdated tasks", error: error)
                updatedTasks.append(contentsOf: outdatedTasks)
                continue
            }

            updatedTasks.append(contentsOf: outdatedTasks.map { task in
                var mutableTask = task
                mutableTask.dueDate = now
                return mutableTask
            })
        }

        return tasks + updatedTasks
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
            guard let lastFetchedContext = lastFetchedContext,
                  Environment.Features.iCloudSyncing,
                  UserDefaults.iCloudSyncingIsEnabled ?? false else { return }

            let dataSources = lastFetchedContext.dataSources
                .appended(.iCloud)
                .uniques()

            Task {
                await getTasks(from: dataSources,
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
