//
//  TasksViewModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import PopperUp
import TasktiveLocale
import ShrimpExtensions

private let logger = Logster(from: TasksViewModel.self)

final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [Date: [AppTask]] = [:]
    @Published private(set) var loadingTasks = false
    @Published private(set) var settingTasks = false

    private let persistenceController: PersistenceController
    private let dataClient = DataClient()

    init() {
        self.persistenceController = .shared
    }

    #if DEBUG
    init(preview: Bool) {
        if preview {
            self.persistenceController = .preview
        } else {
            self.persistenceController = .shared
        }
    }
    #endif

    var taskDates: [Date] {
        tasks.keys
            .sorted(by: {
                $0.compare($1) == .orderedAscending
            })
    }

    func setTickOnTask(_ task: AppTask, with newTickedState: Bool) async -> Result<Void, UserErrors> {
        await withSettingTasks(completion: {
            let dateHash = getHashDate(from: task.dueDate)
            guard let taskIndex = tasks[dateHash]?.findIndex(by: \.id, is: task.id)
            else { return .failure(.updateFailure) }

            let arguments = task.toggleCoreTaskTickArguments(with: newTickedState)
            let result = dataClient.update(
                by: task.id,
                with: arguments,
                from: persistenceController.context,
                of: CoreTask.self
            )
            .mapError {
                let error: Error?
                switch $0 {
                case .notFound:
                    logger.error("task not found")
                    return UserErrors.updateFailure
                case let .crud(error: crudError):
                    error = crudError as? CoreTask.CrudErrors
                }

                guard let error = error else { return UserErrors.updateFailure }

                logger.error("failed to update this task; error='\(error)'")
                return UserErrors.updateFailure
            }
            let updatedTask: CoreTask.ReturnType
            switch result {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                updatedTask = success
            }

            var mutableTask = tasks
            mutableTask[dateHash]?[taskIndex] = updatedTask.asAppTask
            await setTasks(mutableTask)

            return .success(())
        })
    }

    func tasksForDate(_ date: Date) -> [AppTask] {
        tasks[getHashDate(from: date)] ?? []
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

    func createTask(with arguments: CoreTask.Arguments) async -> Result<Void, UserErrors> {
        let result = dataClient.create(with: arguments, from: persistenceController.context, of: CoreTask.self)
            .mapError {
                logger.error("failed to create this task; error='\($0)'")
                return UserErrors.createTaskFailure
            }
            .map(\.asAppTask)

        let task: AppTask
        switch result {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            task = success
        }

        var tempTasks = tasks
        let hashDate = getHashDate(from: task.dueDate)
        if tempTasks[hashDate] == nil {
            tempTasks[hashDate] = [task]
        } else {
            tempTasks[hashDate] = tempTasks[hashDate] ?? [] + [task]
        }

        await setTasks(tempTasks)

        return .success(())
    }

    func getAllTasks() async -> Result<Void, UserErrors> {
        await withLoadingTasks {
            let tasksResult = dataClient.list(from: persistenceController.context, of: CoreTask.self)
                .mapError {
                    logger.error("failed to get all tasks; error='\($0)'")
                    return UserErrors.getAllFailure
                }

            let tasks: [CoreTask]
            switch tasksResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                tasks = success
            }

            let maybeUpdatedTasks = updateDueDateOfTasksIfNeeded(tasks.map(\.asAppTask))

            let groupedTasks = Dictionary(grouping: maybeUpdatedTasks, by: {
                getHashDate(from: $0.dueDate)
            })

            await setTasks(groupedTasks)

            return .success(())
        }
    }

    private func updateDueDateOfTasksIfNeeded(_ tasks: [AppTask]) -> [AppTask] {
        let tasksGroupedByDueDateIsBeforeToday = Dictionary(grouping: tasks, by: {
            $0.dueDate.isBeforeToday && !$0.ticked
        })
        guard let tasksFromDaysBefore = tasksGroupedByDueDateIsBeforeToday[true] else { return tasks }

        let now = Date()
        let updateResult = dataClient.updateManyTaskDates(
            by: tasksFromDaysBefore.map(\.id),
            date: now,
            context: persistenceController.context
        )

        switch updateResult {
        case let .failure(failure):
            logger.error("failed to updated outdated tasks; error='\(failure)'")
        case .success:
            break
        }

        let notUpdatedTasks = tasksGroupedByDueDateIsBeforeToday[false]?.map(\.asAppTask) ?? []
        let updatedTasks = tasksFromDaysBefore
            .map {
                var task = $0.asAppTask
                task.dueDate = now
                return task
            }

        return notUpdatedTasks + updatedTasks
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
    private func setTasks(_ tasks: [Date: [AppTask]]) {
        self.tasks = tasks
    }
}

extension TasksViewModel {
    enum UserErrors: PopUpError, Error {
        case getAllFailure
        case createTaskFailure
        case updateFailure

        var style: PopperUpStyles {
            switch self {
            case .getAllFailure:
                return .bottom(
                    title: TasktiveLocale.Keys.SOMETHING_WENT_WRONG_ERROR_TITLE.localized,
                    type: .error,
                    description: TasktiveLocale.Keys.GET_ALL_TASKS_ERROR_DESCRIPTION.localized
                )
            case .createTaskFailure:
                return .bottom(
                    title: TasktiveLocale.Keys.SOMETHING_WENT_WRONG_ERROR_TITLE.localized,
                    type: .error,
                    description: TasktiveLocale.Keys.CREATE_TASK_ERROR_DESCRIPTION.localized
                )
            case .updateFailure:
                #warning("localize this")
                return .bottom(
                    title: TasktiveLocale.Keys.SOMETHING_WENT_WRONG_ERROR_TITLE.localized,
                    type: .error,
                    description: "We couldn't update this task"
                )
            }
        }

        var timeout: TimeInterval? {
            5
        }
    }
}
