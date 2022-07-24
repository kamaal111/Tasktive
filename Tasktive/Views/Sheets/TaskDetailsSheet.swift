//
//  TaskDetailsSheet.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI

private let logger = Logster(from: TaskDetailsSheet.self)

struct TaskDetailsSheet: View {
    @StateObject private var viewModel = ViewModel()

    let task: AppTask?
    let onClose: () -> Void
    let onDone: (_ arguments: CoreTask.Arguments?) -> Void

    var body: some View {
        KSheetStack(
            title: viewModel.title,
            leadingNavigationButton: {
                // - TODO: LOCALIZE THIS
                ToolbarButton(text: "Close", action: onClose)
            },
            trailingNavigationButton: {
                // - TODO: LOCALIZE THIS
                ToolbarButton(text: "Done", action: { onDone(viewModel.makeCoreTaskArguments(using: task)) })
            }
        ) {
            VStack {
                // - TODO: LOCALIZE THIS
                KFloatingTextField(text: $viewModel.title, title: "Title")
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

        init() { }

        func makeCoreTaskArguments(using task: AppTask?) -> CoreTask.Arguments? {
            guard let task else {
                logger.warning("could not make task arguments")
                return nil
            }

            var arguments = task.coreTaskArguments
            arguments.title = title

            return arguments
        }

        @MainActor
        func setValues(from task: AppTask?) {
            guard let task else {
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
            task: try! CoreTask.list(from: PersistenceController.preview.context).get().first!.asAppTask,
            onClose: { },
            onDone: { _ in }
        )
    }
}
