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
private let logger = Logster(from: TasksScreen.self)

struct TasksScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var tasksViewModel: TasksViewModel
    @EnvironmentObject private var popperUpManager: PopperUpManager

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            VStack {
                List {
                    DateControlView(
                        goToPreviousDay: { Task { await viewModel.goToPreviousDay() } },
                        goToToday: { Task { await viewModel.goToToday() } },
                        goToNextDay: { Task { await viewModel.goToNextDay() } }
                    )
                    .disabled(tasksViewModel.loadingTasks)
                    ProgressSection(
                        currentDate: viewModel.currentDay,
                        progress: tasksViewModel.progressForDate(viewModel.currentDay)
                    )
                    TasksSection(
                        tasks: tasksViewModel.tasksForDate(viewModel.currentDay),
                        loading: tasksViewModel.loadingTasks
                    )
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
        @Published private(set) var currentDay = Date()

        init() { }

        var disableNewTaskSubmitButton: Bool {
            invalidTitle
        }

        func goToToday() async {
            let now = Date()
            guard !currentDay.isSameDay(as: now) else { return }
            await setCurrentDay(now)
        }

        func goToPreviousDay() async {
            let previousDate = incrementDay(of: currentDay, by: -1)
            await setCurrentDay(previousDate)
        }

        func goToNextDay() async {
            let previousDate = incrementDay(of: currentDay, by: 1)
            await setCurrentDay(previousDate)
        }

        func submitNewTask() async -> Result<String, ValidationErrors> {
            guard !invalidTitle else {
                return .failure(.invalidTitle)
            }

            let title = newTitle

            await setTitle("")

            return .success(title)
        }

        private var invalidTitle: Bool {
            newTitle.trimmingByWhitespacesAndNewLines.isEmpty
        }

        private func incrementDay(of date: Date, by increment: Int) -> Date {
            var dateComponent = DateComponents()
            dateComponent.day = increment

            guard let incrementedDate = Calendar.current.date(byAdding: dateComponent, to: date) else {
                logger.error("coul not set previous date")
                return date
            }

            return incrementedDate
        }

        @MainActor
        private func setCurrentDay(_ date: Date) {
            withAnimation {
                currentDay = date
            }
        }

        @MainActor
        private func setTitle(_ title: String) {
            newTitle = title
        }
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
                return TasktiveLocale.Keys.INVALID_TITLE_ERROR_TITLE.localized
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

        return ForEach(ColorScheme.allCases, id: \.self) { scheme in
            MainView()
                .previewEnvironment(withConfiguration: configuration)
                .colorScheme(scheme)
        }
    }
}
