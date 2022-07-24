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
    let isFocused: Bool
    let onTaskTick: (_ newTickedState: Bool) -> Void
    let focusOnTask: () -> Void
    let onDetailsPress: () -> Void

    init(
        task: AppTask,
        isFocused: Bool,
        onTaskTick: @escaping (_ newTickedState: Bool) -> Void,
        focusOnTask: @escaping () -> Void,
        onDetailsPress: @escaping () -> Void
    ) {
        self.task = task
        self.isFocused = isFocused
        self.onTaskTick = onTaskTick
        self.focusOnTask = focusOnTask
        self.onDetailsPress = onDetailsPress
    }

    var body: some View {
        HStack {
            KTappableButton(action: { onTaskTick(!task.ticked) }) {
                KRadioCheckBox(checked: task.ticked, size: 16)
            }
            Button(action: focusOnTask) {
                Text(task.title)
                    .strikethrough(task.ticked)
                    .foregroundColor(task.ticked ? .secondary : .primary)
            }
            .ktakeWidthEagerly(alignment: .leading)
            if isFocused {
                KTappableButton(action: onDetailsPress) {
                    Image(systemName: "info.circle")
                        .bold()
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        let tasks = try! CoreTask.list(from: PersistenceController.preview.context).get()

        return List {
            TaskItemView(
                task: tasks[1].asAppTask,
                isFocused: true,
                onTaskTick: { _ in },
                focusOnTask: { },
                onDetailsPress: { }
            )
            TaskItemView(
                task: tasks[2].asAppTask,
                isFocused: false,
                onTaskTick: { _ in },
                focusOnTask: { },
                onDetailsPress: { }
            )
        }
    }
}
