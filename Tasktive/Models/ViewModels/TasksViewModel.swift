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

    private let dataClient: DataClient

    init() {
        #if !DEBUG
        self.dataClient = .init(persistenceController: .shared, skypiea: .shared)
        #else
        if CommandLineArguments.previewCoredata.enabled {
            self.dataClient = .init(persistenceController: .preview, skypiea: .preview)
        } else {
            self.dataClient = .init(persistenceController: .shared, skypiea: .shared)
        }
        #endif
    }

    #if DEBUG
    init(preview: Bool) {
        if preview || CommandLineArguments.previewCoredata.enabled {
            self.dataClient = .init(persistenceController: .preview, skypiea: .preview)
        } else {
            self.dataClient = .init(persistenceController: .shared, skypiea: .shared)
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
        await getTasks(from: sources, for: date, updateNotCompletedTasks: false)
    }

    func getTodaysTasks(from sources: [DataSource]) async -> Result<Void, UserErrors> {
        await getTasks(from: sources, for: Date(), updateNotCompletedTasks: true)
    }

    func getAllTasks(from sources: [DataSource],
                     updateNotCompletedTasks: Bool = true) async -> Result<Void, UserErrors> {
        await getTasksByPredicate(from: sources, by: nil, updateNotCompletedTasks: updateNotCompletedTasks)
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

    private func getTasks(from sources: [DataSource],
                          for date: Date,
                          updateNotCompletedTasks: Bool) async -> Result<Void, UserErrors> {
        let startDate = getHashDate(from: date)
        let endDate = getHashDate(from: startDate.incrementByDays(1)).incrementBySeconds(-1)

        let queryString = "(dueDate >= \(startDate.asNSDate)) AND (dueDate <= \(endDate.asNSDate))"
        return await getTasksByPredicate(
            from: sources,
            by: queryString,
            updateNotCompletedTasks: updateNotCompletedTasks
        )
    }

    private func getTasksByPredicate(from sources: [DataSource],
                                     by queryString: String?,
                                     updateNotCompletedTasks: Bool) async -> Result<Void, UserErrors> {
        await withLoadingTasks {
            var appTasks: [AppTask] = []

            for source in sources {
                let tasksResult = await getFilteredTasks(from: source, by: queryString)

                switch tasksResult {
                case let .failure(failure):
                    return .failure(failure)
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

            // - TODO: WRITE THIS BETTER
            for (date, tasks) in groupedTasks {
                await setTasks(tasks, forDate: date)
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
            return .failure(.getAllFailure)
        }

        return .success(tasks)
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
        let queryString = "(dueDate < \(today)) AND ticked == NO AND NOT(id in \(tasksIDs))"

        var outdatedTasksBySource: [DataSource: [AppTask]] = [:]

        for source in sources {
            let outdatedTasks = try? await dataClient.tasks.filter(from: source, by: queryString)

            outdatedTasksBySource[source] = (outdatedTasks ?? [])
                .map { task in
                    var mutableTask = task
                    mutableTask.dueDate = now
                    return mutableTask
                }
        }

        for source in sources {
            if let outdatedTasks = outdatedTasksBySource[source], !outdatedTasks.isEmpty {
                do {
                    try await dataClient.tasks.updateManyDates(outdatedTasks, from: source, date: now)
                } catch {
                    logger.error(label: "failed to updated outdated tasks", error: error)
                    return tasks
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
