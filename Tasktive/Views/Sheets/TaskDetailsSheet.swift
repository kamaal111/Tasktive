//
//  TaskDetailsSheet.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import Logster
import SalmonUI
import Environment
import SharedModels
import TasktiveLocale

private let logger = Logster(from: TaskDetailsSheet.self)

struct TaskDetailsSheet: View {
    @StateObject private var viewModel = ViewModel()

    let task: AppTask?
    let availableSources: [DataSource]
    let currentDate: Date
    let onClose: () -> Void
    let onDone: (_ arguments: TaskArguments?, _ reminderTime: Date?, _ newSource: DataSource, _ isNew: Bool) -> Void

    var body: some View {
        KSheetStack(
            title: viewModel.title,
            leadingNavigationButton: {
                ToolbarButton(localized: .CLOSE, action: onClose)
            },
            trailingNavigationButton: {
                ToolbarButton(localized: .DONE, action: {
                    var reminderTime: Date?
                    if viewModel.enableReminder, Environment.Features.taskReminders {
                        let reminderTimeComponents = Calendar.current.dateComponents(
                            [.hour, .minute],
                            from: viewModel.reminderTime
                        )
                        let taskDueDateComponents = Calendar.current.dateComponents(
                            [.month, .day, .year],
                            from: viewModel.dueDate
                        )

                        var finalComponents = DateComponents()
                        finalComponents.hour = reminderTimeComponents.hour
                        finalComponents.minute = reminderTimeComponents.minute
                        finalComponents.month = taskDueDateComponents.month
                        finalComponents.day = taskDueDateComponents.day
                        finalComponents.year = taskDueDateComponents.year

                        reminderTime = Calendar.current.date(from: finalComponents)
                    }

                    onDone(
                        viewModel.makeCoreTaskArguments(using: task),
                        reminderTime,
                        viewModel.dataSource,
                        viewModel.isNewTask
                    )
                })
            }
        ) {
            VStack(alignment: .leading) {
                KFloatingTextField(text: $viewModel.title, title: TasktiveLocale.getText(.TITLE))
                KFloatingDatePicker(value: $viewModel.dueDate, title: TasktiveLocale.getText(.DUE_DATE))

                if Environment.Features.taskReminders {
                    if viewModel.enableReminder {
                        KFloatingDatePicker(
                            value: $viewModel.reminderTime,
                            title: TasktiveLocale.getText(.REMINDER),
                            displayedComponents: [.hourAndMinute]
                        )
                        WideButton(action: { viewModel.setEnableReminder(false, currentDay: currentDate) }) {
                            HStack {
                                Image(systemName: "minus.circle")
                                Text(localized: .REMOVE_REMINDER)
                            }
                        }
                        .padding(.top, .extraSmall)
                    } else {
                        WideButton(action: { viewModel.setEnableReminder(true, currentDay: currentDate) }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text(localized: .ADD_REMINDER)
                            }
                        }
                        .padding(.top, .extraSmall)
                    }
                }

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
        @Published var reminderTime = Date()
        @Published private(set) var enableReminder = false

        private(set) var isNewTask = false
        private var originalReminder: AppReminder?

        func makeCoreTaskArguments(using task: AppTask?) -> TaskArguments? {
            if isNewTask {
                let arguments = TaskArguments(
                    title: title,
                    taskDescription: nil,
                    notes: nil,
                    dueDate: dueDate,
                    reminders: task?.remindersArray.map(\.toArguments) ?? []
                )

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
        func setEnableReminder(_ enabled: Bool, currentDay: Date) {
            guard enabled != enableReminder else { return }

            if enabled {
                if let originalReminder {
                    reminderTime = originalReminder.time
                } else {
                    var currentDay = currentDay
                    if currentDay.timeIntervalSince(Date()) <= (60 * 60) {
                        let dateComponents = Calendar.current
                            .dateComponents([.day, .year, .month, .hour], from: currentDay)
                        currentDay = Calendar.current.date(from: dateComponents)?.adding(minutes: 60) ?? currentDay
                    }
                    reminderTime = currentDay
                }
            }

            withAnimation { enableReminder = enabled }
        }

        @MainActor
        func setValues(from task: AppTask?, availableSources: [DataSource]) {
            if let task {
                title = task.title
                dueDate = task.dueDate
                dataSource = task.source

                if let firstReminder = task.remindersArray.first {
                    enableReminder = true
                    originalReminder = firstReminder
                    reminderTime = firstReminder.time
                }

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
        let taskID = UUID(uuidString: "1d7b2a98-0395-4a35-89d6-fcee3e3809cf")!

        return TaskDetailsSheet(
            task: AppTask(
                id: taskID,
                title: "Preview",
                ticked: false,
                dueDate: Date(),
                completionDate: nil,
                creationDate: Date(),
                source: .coreData,
                remindersArray: [
                    .init(
                        id: UUID(uuidString: "6907eaa1-13f0-42ef-ad74-101a5fd6c44a")!,
                        time: Date(),
                        creationDate: Date(),
                        taskID: taskID,
                        source: .coreData
                    ),
                ]
            ),
            availableSources: DataSource.allCases,
            currentDate: Date(),
            onClose: { },
            onDone: { _, _, _, _ in }
        )
    }
}
