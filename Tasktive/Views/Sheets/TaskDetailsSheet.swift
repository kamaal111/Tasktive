//
//  TaskDetailsSheet.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import Logster
import SalmonUI
import SharedModels
import TasktiveLocale

private let logger = Logster(from: TaskDetailsSheet.self)

struct TaskDetailsSheet: View {
    @StateObject private var viewModel = ViewModel()

    let task: AppTask?
    let availableSources: [DataSource]
    let onClose: () -> Void
    let onDone: (_ arguments: TaskArguments?, _ newSource: DataSource, _ isNew: Bool) -> Void

    var body: some View {
        KSheetStack(
            title: viewModel.title,
            leadingNavigationButton: {
                ToolbarButton(localized: .CLOSE, action: onClose)
            },
            trailingNavigationButton: {
                ToolbarButton(localized: .DONE, action: {
                    onDone(viewModel.makeCoreTaskArguments(using: task), viewModel.dataSource, viewModel.isNewTask)
                })
            }
        ) {
            VStack(alignment: .leading) {
                KFloatingTextField(text: $viewModel.title, title: TasktiveLocale.getText(.TITLE))
                KFloatingDatePicker(value: $viewModel.dueDate, title: TasktiveLocale.getText(.DUE_DATE))

                if availableSources.count > 1 {
                    Text(localized: .LOCATION)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .padding(.bottom, -(AppSizes.small.rawValue))
                        .padding(.top, .extraSmall)
                    VStack {
                        DataSourcePicker(source: $viewModel.dataSource, sources: availableSources, withLabel: true)
                    }
                    .padding(.horizontal, .small)
                }
            }
            .padding(.vertical, .medium)
        }
        .onAppear(perform: {
            viewModel.setValues(from: task, availableSources: availableSources)
        })
    }

    final class ViewModel: ObservableObject {
        @Published var title = ""
        @Published var dueDate = Date()
        @Published var dataSource: DataSource = .coreData

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

                var arguments = task.arguments
                arguments.title = title
                arguments.dueDate = dueDate

                return arguments
            }
        }

        @MainActor
        func setValues(from task: AppTask?, availableSources: [DataSource]) {
            if let task {
                title = task.title
                dueDate = task.dueDate
                dataSource = task.source

                isNewTask = false

                logger.info("task values have set")
            } else {
                dataSource = availableSources.first ?? .coreData

                isNewTask = true

                logger.info("prepared for a new task")
            }
        }
    }
}

struct TaskDetailsSheet_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailsSheet(
            task: AppTask(
                id: UUID(uuidString: "1d7b2a98-0395-4a35-89d6-fcee3e3809cf")!,
                title: "Preview",
                ticked: false,
                dueDate: Date(),
                completionDate: nil,
                creationDate: Date(),
                source: .coreData
            ),
            availableSources: DataSource.allCases,
            onClose: { },
            onDone: { _, _, _ in }
        )
    }
}
