//
//  TasksViewModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI

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

    func getAllTasks() async {
        let tasksResult = dataClient.listTasks(from: persistenceController.context, of: CoreTask.self)
        let tasks: [CoreTask]
        switch tasksResult {
        case let .failure(failure):
            #warning("handle user error")
            print("failure", failure)
            return
        case let .success(success):
            tasks = success
        }

        let groupedTasks = Dictionary(grouping: tasks.map(\.asAppTask), by: { task in
            let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: task.dueDate)
            return Calendar.current.date(from: dateComponents) ?? Date()
        })

        await setTasks(groupedTasks)
    }

    @MainActor
    private func setTasks(_ tasks: [Date: [AppTask]]) {
        self.tasks = tasks
    }
}
