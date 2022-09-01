//
//  TasksViewModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import Skypiea
import PopperUp
import TasktiveLocale
import ShrimpExtensions

private let logger = Logster(from: TasksViewModel.self)

final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [Date: [AppTask]] = [:]
    @Published private(set) var loadingTasks = false
    @Published private(set) var settingTasks = false

    private let persistenceController: PersistenceController
    private let skypiea: Skypiea
    private let tasksClient = TasksClient()

    init() {
        #if !DEBUG
        self.persistenceController = .shared
        self.skypiea = .shared
        #else
        if CommandLineArguments.previewCoredata.enabled {
            self.persistenceController = .preview
            self.skypiea = .preview
        } else {
            self.persistenceController = .shared
            self.skypiea = .shared
        }
        #endif
    }

    #if DEBUG
    init(preview: Bool) {
        if preview || CommandLineArguments.previewCoredata.enabled {
            self.persistenceController = .preview
            self.skypiea = .preview
        } else {
            self.persistenceController = .shared
            self.skypiea = .shared
        }
    }
    #endif

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
        let result: Result<AppTask, UserErrors>
        switch source {
        case .coreData:
            result = await tasksClient
                .create(with: arguments, from: persistenceController.context, of: CoreTask.self)
                .mapError {
                    logger.error(label: "failed to create this task", error: $0)
                    return UserErrors.createTaskFailure
                }
        case .iCloud:
            result = await tasksClient
                .create(with: arguments, from: skypiea, of: CloudTask.self)
                .mapError {
                    logger.error(label: "failed to create this task", error: $0)
                    return UserErrors.createTaskFailure
                }
        }

        let task: AppTask
        switch result {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            task = success
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
        await getTasks(from: sources, for: date, updateNotCompletedTasks: false)
    }

    func getTodaysTasks(from sources: [DataSource]) async -> Result<Void, UserErrors> {
        await getTasks(from: sources, for: Date(), updateNotCompletedTasks: true)
    }

    func getAllTasks(from sources: [DataSource],
                     updateNotCompletedTasks: Bool = true) async -> Result<Void, UserErrors> {
        let predicate = NSPredicate(value: true)
        return await getTasksByPredicate(from: sources, by: predicate, updateNotCompletedTasks: updateNotCompletedTasks)
    }

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

            let result: Result<AppTask, UserErrors>
            switch task.source {
            case .coreData:
                result = await tasksClient.update(
                    by: task.id,
                    with: arguments,
                    from: persistenceController.context,
                    of: CoreTask.self
                )
                .mapError {
                    // - TODO: MAKE THIS A FUNCTION TO REUSE FOR BELLOW
                    let error: Error?
                    switch $0 {
                    case .notFound:
                        logger.error("task not found")
                        return UserErrors.updateFailure
                    case let .crud(error: crudError):
                        error = crudError as? CoreTask.CrudErrors
                    }

                    guard let error = error else { return UserErrors.updateFailure }

                    logger.error(label: "failed to update this task", error: error)
                    return UserErrors.updateFailure
                }
            case .iCloud:
                result = await tasksClient.update(
                    by: task.id,
                    with: arguments,
                    from: skypiea,
                    of: CloudTask.self
                )
                .mapError {
                    // - TODO: MAKE THIS A FUNCTION TO REUSE FOR ABOVE
                    let error: Error?
                    switch $0 {
                    case .notFound:
                        logger.error("task not found")
                        return UserErrors.updateFailure
                    case let .crud(error: crudError):
                        error = crudError as? CloudTask.CrudErrors
                    }

                    guard let error = error else { return UserErrors.updateFailure }

                    logger.error(label: "failed to update this task", error: error)
                    return UserErrors.updateFailure
                }
            }

            let updatedTask: AppTask
            switch result {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                updatedTask = success
            }

            var mutableTask = tasks
            mutableTask[dateHash]?[taskIndex] = updatedTask
            await setTasks(mutableTask[dateHash] ?? [], forDate: dateHash)

            return .success(())
        })
    }

    private func getTasks(from sources: [DataSource],
                          for date: Date,
                          updateNotCompletedTasks: Bool) async -> Result<Void, UserErrors> {
        let startDate = getHashDate(from: date)
        let endDate = getHashDate(from: startDate.incrementByDays(1)).incrementBySeconds(-1)

        let predicate = NSPredicate(format: "(dueDate >= %@) AND (dueDate <= %@)", startDate.asNSDate, endDate.asNSDate)
        return await getTasksByPredicate(from: sources, by: predicate, updateNotCompletedTasks: updateNotCompletedTasks)
    }

    private func getTasksByPredicate(from sources: [DataSource],
                                     by predicate: NSPredicate,
                                     updateNotCompletedTasks: Bool) async -> Result<Void, UserErrors> {
        await withLoadingTasks {
            var appTasks: [AppTask] = []

            for source in sources {
                let tasksResult = await getFilteredTasks(from: source, by: predicate)

                switch tasksResult {
                case let .failure(failure):
                    return .failure(failure)
                case let .success(success):
                    appTasks = success
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

            // - TODO: WRITE THIS BETTER
            for (date, tasks) in groupedTasks {
                await setTasks(tasks, forDate: date)
            }

            return .success(())
        }
    }

    private func getFilteredTasks(from source: DataSource,
                                  by predicate: NSPredicate) async -> Result<[AppTask], TasksViewModel.UserErrors> {
        switch source {
        case .coreData:
            return await tasksClient
                .filter(by: predicate, from: persistenceController.context, of: CoreTask.self)
                .mapError {
                    logger.error(label: "failed to get all tasks", error: $0)
                    return UserErrors.getAllFailure
                }
        case .iCloud:
            return await tasksClient
                .filter(by: predicate, from: skypiea, of: CloudTask.self)
                .mapError {
                    logger.error(label: "failed to get all tasks", error: $0)
                    return UserErrors.getAllFailure
                }
        }
    }

    private func validateTaskArguments(_ arguments: TaskArguments) -> Result<Void, UserErrors> {
        guard !arguments.title.trimmingByWhitespacesAndNewLines.isEmpty else { return .failure(.invalidTitle) }

        return .success(())
    }

    private func updateDueDateOfTasksIfNeeded(_ tasks: [AppTask], enabled: Bool,
                                              sources: [DataSource]) async -> [AppTask] {
        guard enabled else { return tasks }

        let now = Date()
        let today = getHashDate(from: now).asNSDate
        let tasksIDs = tasks.map(\.id.nsString)
        let predicate = NSPredicate(format: "(dueDate < %@) AND ticked == NO AND NOT(id in %@) ", today, tasksIDs)

        var outdatedTasksBySource: [DataSource: [AppTask]] = [:]

        for source in sources {
            let outdatedTasks: [AppTask]?
            switch source {
            case .coreData:
                outdatedTasks = try? await tasksClient.filter(
                    by: predicate,
                    from: persistenceController.context,
                    of: CoreTask.self
                )
                .get()
            case .iCloud:
                outdatedTasks = try? await tasksClient.filter(
                    by: predicate,
                    from: skypiea,
                    of: CloudTask.self
                )
                .get()
            }

            outdatedTasksBySource[source] = (outdatedTasks ?? [])
                .map { task in
                    var mutableTask = task
                    mutableTask.dueDate = now
                    return mutableTask
                }
        }

        for source in DataSource.allCases {
            switch source {
            case .coreData:
                if let outdatedTasks = outdatedTasksBySource[source] {
                    let updateResult = CoreTask.updateManyDates(
                        by: outdatedTasks.map(\.id),
                        date: now,
                        on: persistenceController.context
                    )
                    switch updateResult {
                    case let .failure(failure):
                        logger.error(label: "failed to updated outdated tasks", error: failure)
                        return tasks
                    case .success:
                        break
                    }
                }
            case .iCloud:
                if let outdatedTasks = outdatedTasksBySource[source] {
                    let updateResult = await CloudTask.updateManyDates(
                        by: outdatedTasks.map(\.id),
                        date: now,
                        on: skypiea
                    )
                    switch updateResult {
                    case let .failure(failure):
                        logger.error(label: "failed to updated outdated tasks", error: failure)
                        return tasks
                    case .success:
                        break
                    }
                }
            }
        }

        return tasks + outdatedTasksBySource.flatMap(\.value)
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
}

extension TasksViewModel {
    enum UserErrors: PopUpError, Error {
        case getAllFailure
        case createTaskFailure
        case updateFailure
        case invalidTitle

        var style: PopperUpStyles {
            switch self {
            case .getAllFailure:
                return .bottom(
                    title: TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE),
                    type: .error,
                    description: TasktiveLocale.getText(.GET_ALL_TASKS_ERROR_DESCRIPTION)
                )
            case .createTaskFailure:
                return .bottom(
                    title: TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE),
                    type: .error,
                    description: TasktiveLocale.getText(.CREATE_TASK_ERROR_DESCRIPTION)
                )
            case .updateFailure:
                return .bottom(
                    title: TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE),
                    type: .error,
                    description: TasktiveLocale.getText(.UPDATE_TASK_ERROR_DESCRIPTION)
                )
            case .invalidTitle:
                return .bottom(
                    title: TasktiveLocale.getText(.GENERAL_WARNING_TITLE),
                    type: .warning,
                    description: TasktiveLocale.getText(.INVALID_TITLE_WARNING_DESCRIPTION)
                )
            }
        }

        var timeout: TimeInterval? {
            5
        }
    }
}
