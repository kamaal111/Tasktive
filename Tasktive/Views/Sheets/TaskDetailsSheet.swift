//
//  TaskDetailsSheet.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import Logster
import SalmonUI
import CDPersist
import SharedModels
import TasktiveLocale

private let logger = Logster(from: TaskDetailsSheet.self)

struct TaskDetailsSheet: View {
    @StateObject private var viewModel = ViewModel()

    let task: AppTask?
    let onClose: () -> Void
    let onDone: (_ arguments: TaskArguments?, _ isNew: Bool) -> Void
    let onDelete: () -> Void

    var body: some View {
        KSheetStack(
            title: viewModel.title,
            leadingNavigationButton: {
                ToolbarButton(localized: .CLOSE, action: onClose)
            },
            trailingNavigationButton: {
                ToolbarButton(localized: .DONE, action: {
                    onDone(viewModel.makeCoreTaskArguments(using: task), viewModel.isNewTask)
                })
            }
        ) {
            VStack(alignment: .leading) {
                KFloatingTextField(text: $viewModel.title, title: TasktiveLocale.getText(.TITLE))

                KFloatingDatePicker(value: $viewModel.dueDate, title: TasktiveLocale.getText(.DUE_DATE))

                if !viewModel.isNewTask {
                    Button(action: onDelete) {
                        HStack(spacing: 5) {
                            Image(systemName: "trash")
                            Text(localized: .DELETE)
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.vertical, .small)
                        .ktakeWidthEagerly()
                        .background(Color.accentColor)
                        .cornerRadius(.small)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, .medium)
        }
        .onAppear(perform: {
            viewModel.setValues(from: task)
        })
    }

    final class ViewModel: ObservableObject {
        @Published var title = ""
        @Published var dueDate = Date()

        @Published private(set) var isNewTask = false

        func makeCoreTaskArguments(using task: AppTask?) -> TaskArguments? {
            if isNewTask {
                let arguments = TaskArguments(title: title, taskDescription: nil, notes: nil, dueDate: dueDate)

                return arguments
            } else {
                guard let task = task else {
                    logger.warning("could not make task arguments")
                    return nil
                }

                var arguments = task.coreTaskArguments
                arguments.title = title
                arguments.dueDate = dueDate

                return arguments
            }
        }

        @MainActor
        func setValues(from task: AppTask?) {
            if let task {
                title = task.title
                dueDate = task.dueDate

                isNewTask = false

                logger.info("task values have set")
            } else {
                isNewTask = true

                logger.info("prepared for a new task")
            }
        }
    }
}

struct TaskDetailsSheet_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailsSheet(
            // swiftlint:disable force_try
            task: try! CoreTask.list(from: PersistenceController.preview.context).get().first!.asAppTask,
            onClose: { },
            onDone: { _, _ in },
            onDelete: { }
        )
    }
}
