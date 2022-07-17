//
//  TasksScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale
import ShrimpExtensions

private let SCREEN: NamiNavigator.Screens = .tasks

struct TasksScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var tasksViewModel: TasksViewModel

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(tasksViewModel.taskDates, id: \.self) { date in
                        Section(header: Text(viewModel.formattedDate(date))) {
                            ForEach(tasksViewModel.tasksForDate(date), id: \.self) { task in
                                Text(task.title)
                            }
                        }
                    }
                }
            }
            HStack {
                Image(systemName: "plus.circle")
                    .bold()
                    .padding(.top, 12)
                KFloatingTextField(
                    text: $viewModel.newTitle,
                    title: TasktiveLocale.Keys.NEW_TASK_INPUT_TITLE.localized,
                    onCommit: { Task { await viewModel.submitNewTask() } }
                )
                Button(action: { Task { await viewModel.submitNewTask() } }) {
                    Text(localized: .SUBMIT)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.disableNewTaskSubmitButton)
            }
            .padding(.horizontal, .medium)
            .padding(.vertical, .small)
            .background(colorScheme == .dark ? Color.black : Color.white)
            .ktakeSizeEagerly(alignment: .bottom)
        }
        .navigationTitle(Text(SCREEN.title))
        .onAppear(perform: {
            Task { await tasksViewModel.getAllTasks() }
        })
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

extension TasksScreen {
    final class ViewModel: ObservableObject {
        @Published var newTitle = ""

        init() { }

        var disableNewTaskSubmitButton: Bool {
            newTitle.trimmingByWhitespacesAndNewLines.isEmpty
        }

        func submitNewTask() async {
            guard !disableNewTaskSubmitButton else { return }

            await setTitle("")
        }

        func formattedDate(_ date: Date) -> String {
            let now = Date()

            #warning("not working for some reason")
            if date.isPreviousDay(of: now) {
                return TasktiveLocale.Keys.YESTERDAY.localized
            }
            if date.isSameDay(as: now) {
                return TasktiveLocale.Keys.TODAY.localized
            }
            if date.isNextDay(of: now) {
                return TasktiveLocale.Keys.TOMORROW.localized
            }
            return Self.taskDateFormatter.string(from: date)
        }

        @MainActor
        private func setTitle(_ title: String) {
            newTitle = title
        }

        private static let taskDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
    }
}

struct TasksScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TasksScreen()
        }
        .previewEnvironment()
    }
}
