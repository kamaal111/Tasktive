//
//  TaskItemView.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI

struct TaskItemView: View {
    let task: AppTask
    let onTaskTick: (_ newTickedState: Bool) -> Void

    init(task: AppTask, onTaskTick: @escaping (_ ticked: Bool) -> Void) {
        self.task = task
        self.onTaskTick = onTaskTick
    }

    var body: some View {
        HStack {
            KTappableButton(action: { onTaskTick(!task.ticked) }) {
                KRadioCheckBox(checked: task.ticked, size: 16)
            }
            Text(task.title)
                .strikethrough(task.ticked)
                .foregroundColor(task.ticked ? .secondary : .primary)
        }
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        let tasks = try! CoreTask.list(from: PersistenceController.preview.context).get()

        return List {
            TaskItemView(task: tasks[1].asAppTask, onTaskTick: { _ in })
            TaskItemView(task: tasks[2].asAppTask, onTaskTick: { _ in })
        }
    }
}
