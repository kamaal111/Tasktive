//
//  TasksStore.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 01/10/2022.
//

import Logster
import Foundation
import SharedModels
import ShrimpExtensions

private let logger = Logster(from: TasksStore.self)

actor TasksStore {
    private(set) var store: [Date: [AppTask]]

    init() {
        self.store = [:]
    }

    func get(_ date: Date) -> [AppTask]? {
        store[date.hashed]
    }

    func set(_ tasks: [AppTask]) {
        let groupedTasks = Dictionary(grouping: tasks, by: {
            $0.dueDate.hashed
        })
        for (date, tasks) in groupedTasks {
            store[date] = tasks
        }
    }

    func update(_ task: AppTask, fromDate source: Date) {
        // Get old task index
        guard let oldTasksArray = get(source), let oldTaskIndex = oldTasksArray.findIndex(by: \.id, is: task.id)
        else { return }

        // Update store with new task
        store[source.hashed]![oldTaskIndex] = task

        // Move task if needed
        move(task, from: source, to: task.dueDate)
    }

    func move(_ task: AppTask, from source: Date, to destination: Date) {
        if task.dueDate.hashed != destination.hashed {
            #if DEBUG
            fatalError("task due date should be the same as the destination")
            #else
            logger.warning("task due date should be the same as the destination")
            #endif
        }

        guard source != destination else { return }

        remove(task, fromDate: source)
        add(task)
    }

    @discardableResult
    func remove(_ task: AppTask, fromDate date: Date) -> AppTask? {
        guard var tasks = get(date), let index = tasks.findIndex(by: \.id, is: task.id) else { return .none }

        let removedTask = tasks.remove(at: index)

        set(tasks)

        return removedTask
    }

    @discardableResult
    func add(_ tasks: [AppTask]) -> [AppTask] {
        let groupedTasks = Dictionary(grouping: tasks, by: {
            $0.dueDate.hashed
        })

        var tasksSet: [AppTask] = []
        for (date, tasks) in groupedTasks {
            if let previouslyFetchedItems = get(date) {
                let tasks: [AppTask] = tasks
                    .concat(previouslyFetchedItems)
                    .reduce([]) { result, task in
                        if !result.contains(where: { $0.id == task.id }) {
                            return result.appended(task)
                        }
                        return result
                    }
                store[date] = tasks
                tasksSet.append(contentsOf: tasks)
            } else {
                store[date] = tasks
                tasksSet.append(contentsOf: tasks)
            }
        }

        return tasksSet
    }

    func add(_ task: AppTask) {
        let date = task.dueDate.hashed
        let items = (get(date) ?? []).appended(task)
        store[date] = items
    }
}
