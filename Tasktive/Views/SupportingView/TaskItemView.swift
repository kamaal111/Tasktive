//
//  TaskItemView.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI

private let RADIO_SIZE: CGFloat = 16

struct TaskItemView: View {
    @Environment(\.isEnabled) var isEnabled

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
            radioButton
            KJustStack {
                #if os(macOS)
                titleView
                #else
                Button(action: focusOnTask) {
                    titleView
                }
                #endif
            }
            .ktakeWidthEagerly(alignment: .leading)
            if isFocused {
                KTappableButton(action: onDetailsPress) {
                    Image(systemName: "info.circle")
                        .bold()
                        .foregroundColor(isEnabled ? .accentColor : .secondary)
                }
            }
        }
        .onHover(perform: { isHovering in
            if isHovering {
                focusOnTask()
            }
        })
    }

    private var radioButton: some View {
        #if os(macOS)
        Button(action: clickOnRadioView) {
            radioView
                .frame(width: RADIO_SIZE * 1.5, height: RADIO_SIZE * 1.5)
        }
        .buttonStyle(.borderless)
        #else
        KTappableButton(action: clickOnRadioView) {
            radioView
        }
        #endif
    }

    private var radioView: some View {
        KRadioCheckBox(checked: task.ticked, size: RADIO_SIZE)
            .foregroundColor(isEnabled ? .accentColor : .secondary)
    }

    private var titleView: some View {
        Text(task.title)
            .strikethrough(task.ticked)
            .foregroundColor(task.ticked || !isEnabled ? .secondary : .primary)
    }

    private func clickOnRadioView() {
        onTaskTick(!task.ticked)
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
