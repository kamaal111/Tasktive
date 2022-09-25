//
//  TaskItemView.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI
import CDPersist
import SharedModels

private let RADIO_SIZE: CGFloat = 16

struct TaskItemView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.editMode) private var editMode

    @State private var isDeleting = false

    let task: AppTask
    let isFocused: Bool
    let hasADivider: Bool
    let onTaskTick: (_ newTickedState: Bool) -> Void
    let focusOnTask: () -> Void
    let onDetailsPress: () -> Void
    let onDelete: (_ task: AppTask) -> Void

    init(
        task: AppTask,
        isFocused: Bool,
        hasADivider: Bool,
        onTaskTick: @escaping (_ newTickedState: Bool) -> Void,
        focusOnTask: @escaping () -> Void,
        onDetailsPress: @escaping () -> Void,
        onDelete: @escaping (_ task: AppTask) -> Void
    ) {
        self.task = task
        self.isFocused = isFocused
        self.hasADivider = hasADivider
        self.onTaskTick = onTaskTick
        self.focusOnTask = focusOnTask
        self.onDetailsPress = onDetailsPress
        self.onDelete = onDelete
    }

    var body: some View {
        VStack {
            #if os(macOS)
            KDeletableView(isDeleting: $isDeleting, enabled: editMode.isEditing, onDelete: { onDelete(task) }) {
                mainView
            }
            if hasADivider {
                Divider()
            }
            #else
            mainView
            #endif
        }
    }

    private var mainView: some View {
        HStack {
            radioButton
            titleView
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
        let textView = Text(task.title)
            .strikethrough(task.ticked)
            .foregroundColor(task.ticked || !isEnabled ? .secondary : .primary)

        #if os(macOS)
        return textView
        #else
        return Button(action: focusOnTask) {
            textView
        }
        #endif
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
                hasADivider: false,
                onTaskTick: { _ in },
                focusOnTask: { },
                onDetailsPress: { },
                onDelete: { _ in }
            )
            TaskItemView(
                task: tasks[2].asAppTask,
                isFocused: false,
                hasADivider: false,
                onTaskTick: { _ in },
                focusOnTask: { },
                onDetailsPress: { },
                onDelete: { _ in }
            )
        }
    }
}
