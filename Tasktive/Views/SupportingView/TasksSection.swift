//
//  TasksSection.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI

struct TasksSection: View {
    let tasks: [AppTask]
    let loading: Bool
    let onTaskTick: (_ task: AppTask, _ newTickedState: Bool) -> Void

    var body: some View {
        // - TODO: LOCALIZE THIS
        Section(header: Text("Tasks")) {
            if loading {
                LoadingView()
                    .ktakeWidthEagerly()
            } else if tasks.isEmpty {
                Text(localized: .ADD_NEW_TASK)
                    .ktakeWidthEagerly()
            }
            ForEach(tasks, id: \.self) { task in
                TaskItemView(task: task, onTaskTick: { ticked in onTaskTick(task, ticked) })
            }
        }
    }
}

struct TasksSection_Previews: PreviewProvider {
    static var previews: some View {
        TasksSection(tasks: [], loading: false, onTaskTick: { _, _ in })
    }
}
