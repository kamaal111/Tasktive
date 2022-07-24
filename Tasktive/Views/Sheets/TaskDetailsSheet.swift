//
//  TaskDetailsSheet.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI

struct TaskDetailsSheet: View {
    let task: AppTask?
    let onClose: () -> Void
    let onDone: (_ arguments: CoreTask.Arguments?) -> Void

    var body: some View {
        KSheetStack(
            title: task?.title ?? "",
            leadingNavigationButton: {
                // - TODO: LOCALIZE THIS
                ToolbarButton(text: "Close", action: onClose)
            },
            trailingNavigationButton: {
                // - TODO: LOCALIZE THIS
                ToolbarButton(text: "Done", action: { onDone(task?.coreTaskArguments) })
            }
        ) {
            VStack {
                Text("Hello, World!")
            }
            .padding(.vertical, .medium)
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
