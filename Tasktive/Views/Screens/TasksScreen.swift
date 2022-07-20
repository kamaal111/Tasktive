//
//  TasksScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import SalmonUI
import PopperUp
import TasktiveLocale
import ShrimpExtensions

private let SCREEN: NamiNavigator.Screens = .tasks

struct TasksScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var tasksViewModel: TasksViewModel
    @EnvironmentObject private var popperUpManager: PopperUpManager

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            VStack {
                List {
                    if tasksViewModel.loadingTasks {
                        KActivityIndicator(isAnimating: .constant(true), style: .large)
                            .ktakeWidthEagerly()
                    } else if tasksViewModel.tasks.isEmpty {
                        #warning("Localize this")
                        Text("✨ Add your first task bellow ✨")
                            .ktakeWidthEagerly()
                    }
                    ForEach(tasksViewModel.taskDates, id: \.self) { date in
                        Section(header: Text(viewModel.formattedDate(date))) {
                            ForEach(tasksViewModel.tasksForDate(date), id: \.self) { task in
                                Text(task.title)
                            }
                        }
                    }
                }
            }
            QuickAddTaskField(
                title: $viewModel.newTitle,
                disableSubmit: viewModel.disableNewTaskSubmitButton,
                submit: onNewTaskSubmit
            )
            .padding(.horizontal, .medium)
            #if os(macOS)
                .padding(.vertical, .medium)
            #else
                .padding(.vertical, .small)
            #endif
                .background(colorScheme == .dark ? Color.black : Color.white)
                .ktakeSizeEagerly(alignment: .bottom)
        }
        .navigationTitle(Text(SCREEN.title))
        .onAppear(perform: handleOnAppear)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
        #endif
    }

    private func handleOnAppear() {
        Task {
            let result = await tasksViewModel.getAllTasks()
            switch result {
            case let .failure(failure):
                popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                return
            case .success:
                break
            }
        }
    }

    private func onNewTaskSubmit() {
        Task {
            let submitTaskResult = await viewModel.submitNewTask()
            let newTitle: String
            switch submitTaskResult {
            case let .failure(failure):
                popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                return
            case let .success(success):
                newTitle = success
            }

            let createTaskResult = await tasksViewModel
                .createTask(with: .init(title: newTitle, taskDescription: nil, notes: nil, dueDate: Date()))
            switch createTaskResult {
            case let .failure(failure):
                popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                return
            case .success:
                break
            }

            popperUpManager.showPopup(
                style: .bottom(title: "New task saved", type: .success, description: nil),
                timeout: 2
            )
        }
    }
}

extension TasksScreen {
    final class ViewModel: ObservableObject {
        @Published var newTitle = ""

        init() { }

        var disableNewTaskSubmitButton: Bool {
            invalidTitle
        }

        func submitNewTask() async -> Result<String, ValidationErrors> {
            guard !invalidTitle else {
                return .failure(.invalidTitle)
            }

            let title = newTitle

            await setTitle("")

            return .success(title)
        }

        func formattedDate(_ date: Date) -> String {
            let now = Date()

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

        private var invalidTitle: Bool {
            newTitle.trimmingByWhitespacesAndNewLines.isEmpty
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

extension TasksScreen.ViewModel {
    enum ValidationErrors: PopUpError, Error {
        case invalidTitle

        var style: PopperUpStyles {
            switch self {
            case .invalidTitle:
                return .bottom(title: title, type: .warning, description: description)
            }
        }

        var timeout: TimeInterval? {
            3
        }

        private var title: String {
            switch self {
            case .invalidTitle:
                #warning("Localize this")
                return "Invalid title"
            }
        }

        private var description: String? {
            switch self {
            case .invalidTitle:
                return nil
            }
        }
    }
}

struct TasksScreen_Previews: PreviewProvider {
    static var previews: some View {
        var configuration = PreviewConfiguration()
        configuration.screen = .tasks

        return MainView()
            .previewEnvironment(withConfiguration: configuration)
    }
}
