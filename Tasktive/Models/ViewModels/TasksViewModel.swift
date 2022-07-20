//
//  TasksViewModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import PopperUp

private let logger = Logster(from: TasksViewModel.self)

final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [Date: [AppTask]] = [:]

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
        let result = dataClient.createTask(with: arguments, from: persistenceController.context, of: CoreTask.self)
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
        let tasksResult = dataClient.listTasks(from: persistenceController.context, of: CoreTask.self)
        let tasks: [AppTask]
        switch tasksResult {
        case let .failure(failure):
            logger.error("failed to get all tasks; error='\(failure)'")
            return .failure(.getAllFailure)
        case let .success(success):
            tasks = success
                .map(\.asAppTask)
        }

        let groupedTasks = Dictionary(grouping: tasks, by: { task in
            getHashDate(from: task.dueDate)
        })

        await setTasks(groupedTasks)

        return .success(())
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
