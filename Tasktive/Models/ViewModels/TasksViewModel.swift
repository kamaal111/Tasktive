//
//  TasksViewModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI

final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [AppTask] = []

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

        let sortedTasks = tasks
            .map(\.asAppTask)
            .sorted(by: \.dueDate, using: .orderedAscending)
        print("sortedTasks", sortedTasks)
        await setTasks(sortedTasks)
    }

    @MainActor
    private func setTasks(_ tasks: [AppTask]) {
        self.tasks = tasks
    }
}
