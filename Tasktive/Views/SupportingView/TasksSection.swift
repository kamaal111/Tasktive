//
//  TasksSection.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale
import ShrimpExtensions

struct TasksSection: View {
    let tasks: [AppTask]
    let loading: Bool
    let currentFocusedTaskID: UUID?
    let onTaskTick: (_ task: AppTask, _ newTickedState: Bool) -> Void
    let focusOnTask: (_ task: AppTask) -> Void
    let onDetailsPress: (_ task: AppTask) -> Void
    let onDelete: (_ task: AppTask) -> Void

    var body: some View {
        KSection(header: TasktiveLocale.getText(.TASKS)) {
            if loading {
                KLoading()
                    .ktakeWidthEagerly()
            } else if tasks.isEmpty {
                Text(localized: .ADD_NEW_TASK)
                    .ktakeWidthEagerly()
            }
            ForEach(tasks, id: \.self) { task in
                TaskItemView(
                    task: task,
                    isFocused: task.id == currentFocusedTaskID,
                    hasADivider: task != tasks.last,
                    onTaskTick: { ticked in onTaskTick(task, ticked) },
                    focusOnTask: { focusOnTask(task) },
                    onDetailsPress: { onDetailsPress(task) },
                    onDelete: { task in onDelete(task) }
                )
            }
            .onDelete(perform: { indices in
                for index in indices {
                    guard let task = tasks.at(index) else { break }

                    onDelete(task)
                    break
                }
            })
        }
    }
}

struct TasksSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TasksSection(
                tasks: [],
                loading: false,
                currentFocusedTaskID: nil,
                onTaskTick: { _, _ in },
                focusOnTask: { _ in },
                onDetailsPress: { _ in },
                onDelete: { _ in }
            )
        }
    }
}
