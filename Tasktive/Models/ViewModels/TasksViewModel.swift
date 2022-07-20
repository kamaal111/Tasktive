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
            let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: task.dueDate)
            return Calendar.current.date(from: dateComponents) ?? Date()
        })

        await setTasks(groupedTasks)

        return .success(())
    }

    @MainActor
    private func setTasks(_ tasks: [Date: [AppTask]]) {
        self.tasks = tasks
    }
}

extension TasksViewModel {
    enum UserErrors: PopUpError, Error {
        case getAllFailure

        var style: PopperUpStyles {
            switch self {
            case .getAllFailure:
                #warning("Localize this")
                return .bottom(title: "Something went wrong", type: .error, description: "We couldn't get your tasks")
            }
        }

        var timeout: TimeInterval? {
            5
        }
    }
}
