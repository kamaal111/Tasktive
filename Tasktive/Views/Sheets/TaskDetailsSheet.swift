//
//  TaskDetailsSheet.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale

private let logger = Logster(from: TaskDetailsSheet.self)

struct TaskDetailsSheet: View {
    @StateObject private var viewModel = ViewModel()

    let task: AppTask?
    let onClose: () -> Void
    let onDone: (_ arguments: CoreTask.Arguments?) -> Void
    let onDelete: () -> Void

    var body: some View {
        KSheetStack(
            title: viewModel.title,
            leadingNavigationButton: {
                ToolbarButton(localized: .CLOSE, action: onClose)
            },
            trailingNavigationButton: {
                ToolbarButton(localized: .DONE, action: { onDone(viewModel.makeCoreTaskArguments(using: task)) })
            }
        ) {
            VStack {
                KFloatingTextField(text: $viewModel.title, title: TasktiveLocale.getText(.TITLE_INPUT_TITLE))

                Button {
                    onDelete()
                } label: {
                    (Text(Image(systemName: "trash")) + Text(" Delete"))
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(width: 250, height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            }
            .padding(.vertical, .medium)
        }
        .onAppear(perform: {
            viewModel.setValues(from: task)
        })
    }
}

extension TaskDetailsSheet {
    final class ViewModel: ObservableObject {
        @Published var title = ""

        func makeCoreTaskArguments(using task: AppTask?) -> CoreTask.Arguments? {
            guard let task = task else {
                logger.warning("could not make task arguments")
                return nil
            }

            var arguments = task.coreTaskArguments
            arguments.title = title

            return arguments
        }

        @MainActor
        func setValues(from task: AppTask?) {
            guard let task = task else {
                logger.warning("could not set values")
                return
            }

            title = task.title

            logger.info("task values have set")
        }
    }
}

struct TaskDetailsSheet_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailsSheet(
            // swiftlint:disable force_try
            task: try! CoreTask.list(from: PersistenceController.preview.context).get().first!.asAppTask,
            onClose: { },
            onDone: { _ in },
            onDelete: { }
        )
    }
}
