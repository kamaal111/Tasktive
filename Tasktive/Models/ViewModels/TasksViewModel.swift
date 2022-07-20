//
//  TasksViewModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import PopperUp
import ShrimpExtensions

private let logger = Logster(from: TasksViewModel.self)

final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [Date: [AppTask]] = [:]
    @Published var loadingTasks = false

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

    func tasksForDate(_ date: Date) -> [AppTask] {
        tasks[date] ?? []
    }

    func createTask(with arguments: CoreTask.Arguments) async -> Result<Void, UserErrors> {
        let result = dataClient.create(with: arguments, from: persistenceController.context, of: CoreTask.self)
        let task: AppTask
        switch result {
        case let .failure(failure):
            logger.error("failed to create this task; error='\(failure)'")
            return .failure(.createTaskFailure)
        case let .success(success):
            task = success.asAppTask
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
            var tasks: [CoreTask]
            switch tasksResult {
            case let .failure(failure):
                logger.error("failed to get all tasks; error='\(failure)'")
                return .failure(.getAllFailure)
            case let .success(success):
                tasks = success
            }

            let tasksGroupedByDueDateIsBeforeToday = Dictionary(grouping: tasks, by: \.dueDate.isBeforeToday)

            var updatedTasks: [AppTask]?
            if let tasksFromDaysBefore = tasksGroupedByDueDateIsBeforeToday[true] {
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
                    updatedTasks = (tasksGroupedByDueDateIsBeforeToday[false]?.map(\.asAppTask) ?? []) +
                        (tasksFromDaysBefore.map {
                            var task = $0.asAppTask
                            task.dueDate = now
                            return task
                        })
                    logger.info("successfully updated outdated tasks")
                }
            }

            let groupedTasks = Dictionary(grouping: updatedTasks ?? tasks.map(\.asAppTask), by: { task in
                getHashDate(from: task.dueDate)
            })

            await setTasks(groupedTasks)

            return .success(())
        }
    }

    private func withLoadingTasks<T>(completion: () async -> T) async -> T {
        await setLoadingTasks(true)
        let result = await completion()
        await setLoadingTasks(false)
        return result
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

        var style: PopperUpStyles {
            switch self {
            case .getAllFailure:
                #warning("Localize this")
                return .bottom(title: "Something went wrong", type: .error, description: "We couldn't get your tasks")
            case .createTaskFailure:
                #warning("Localize this")
                return .bottom(title: "Something went wrong", type: .error, description: "We couldn't create this task")
            }
        }

        var timeout: TimeInterval? {
            5
        }
    }
}
