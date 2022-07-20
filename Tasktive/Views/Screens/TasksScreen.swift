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
import PopperUp

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
                    ForEach(tasksViewModel.taskDates, id: \.self) { date in
                        Section(header: Text(viewModel.formattedDate(date))) {
                            ForEach(tasksViewModel.tasksForDate(date), id: \.self) { task in
                                Text(task.title)
                            }
                        }
                    }
                }
            }
            QuickAddTaskField(title: $viewModel.newTitle, submit: onNewTaskSubmit)
                .disabled(viewModel.disableNewTaskSubmitButton)
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
            case .failure(let failure):
                popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                return
            case .success:
                break
            }
        }
    }

    private func onNewTaskSubmit() {
        Task {
            let result = await viewModel.submitNewTask()
            let newTitle: String
            switch result {
            case .failure(let failure):
                popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                return
            case .success(let success):
                newTitle = success
            }
            print("newTitle", newTitle)
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
