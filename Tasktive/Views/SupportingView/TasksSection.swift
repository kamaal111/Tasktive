//
//  TasksSection.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale

struct TasksSection: View {
    let tasks: [AppTask]
    let loading: Bool
    let currentFocusedTaskID: UUID?
    let onTaskTick: (_ task: AppTask, _ newTickedState: Bool) -> Void
    let focusOnTask: (_ task: AppTask) -> Void
    let onDetailsPress: (_ task: AppTask) -> Void
    let onDelete: (_ atOffsets: IndexSet) -> Void

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
                VStack {
                    TaskItemView(
                        task: task,
                        isFocused: task.id == currentFocusedTaskID,
                        onTaskTick: { ticked in onTaskTick(task, ticked) },
                        focusOnTask: { focusOnTask(task) },
                        onDetailsPress: { onDetailsPress(task) }
                    )
                    #if os(macOS)
                    if task != tasks.last {
                        Divider()
                    }
                    #endif
                }
            }
            .onDelete(perform: onDelete)
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
