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

    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var tasksViewModel: TasksViewModel
    @EnvironmentObject private var popperUpManager: PopperUpManager

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            List {
                DateControlView(
                    goToPreviousDay: { Task { await viewModel.goToPreviousDay() } },
                    goToToday: { Task { await viewModel.goToToday() } },
                    goToNextDay: { Task { await viewModel.goToNextDay() } }
                )
                .disabled(tasksViewModel.loadingTasks)
                #if os(macOS) || targetEnvironment(macCatalyst)
                    .padding(.top, .medium)
                    .padding(.horizontal, Constants.UI.mainViewHorizontalWidth)
                #endif
                ProgressSection(
                    currentDate: $viewModel.currentDay,
                    progress: tasksViewModel.progressForDate(viewModel.currentDay)
                )
                #if os(macOS)
                .padding(.horizontal, Constants.UI.mainViewHorizontalWidth)
                #endif
                TasksSection(
                    tasks: tasksViewModel.tasksForDate(viewModel.currentDay),
                    loading: tasksViewModel.loadingTasks,
                    currentFocusedTaskID: viewModel.currentFocusedTaskID,
                    onTaskTick: { task, newTickedState in
                        Task { await tasksViewModel.setTickOnTask(task, with: newTickedState) }
                    },
                    focusOnTask: { task in viewModel.setCurrentFocusedTaskID(task.id) },
                    onDetailsPress: { task in Task { await viewModel.showDetailsSheet(for: task) } }
                )
                .disabled(tasksViewModel.settingTasks)
                #if os(macOS)
                    .padding(.horizontal, Constants.UI.mainViewHorizontalWidth)
                #endif
            }
            .ktakeSizeEagerly(alignment: .topLeading)
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
        .onAppear(perform: handleOnAppear)
        .sheet(isPresented: $viewModel.showTaskDetailsSheet) {
            TaskDetailsSheet(
                task: viewModel.shownTaskDetails,
                onClose: { Task { await viewModel.closeDetailsSheet() } },
                onDone: handleTaskEditedInDetailsSheet(_:)
            )
            .accentColor(theme.currentAccentColor)
            .withPopperUp(popperUpManager)
            #if os(macOS)
                .frame(minWidth: 300, minHeight: 140)
            #endif
        }
    }

    private func handleTaskEditedInDetailsSheet(_ arguments: CoreTask.Arguments?) {
        guard let arguments, let task = viewModel.shownTaskDetails else {
            let message = "task or/and arguments are missing"
            let argumentsLog = "arguments='\(arguments as Any)'"
            let taskLog = "task='\(viewModel.shownTaskDetails as Any)'"
            let loggingMessage = [message, argumentsLog, taskLog].joined(separator: "; ")
            logger.warning(loggingMessage)
            return
        }

        Task {
            let result = await tasksViewModel.updateTask(task, with: arguments)
            switch result {
            case let .failure(failure):
                popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                return
            case .success:
                break
            }

            await viewModel.closeDetailsSheet()
        }
    }

    private func handleOnAppear() {
        Task {
            let result = await tasksViewModel.getTodaysTasks()
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
        logger.info("submitting new task")
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
                .createTask(with: .init(title: newTitle,
                                        taskDescription: nil,
                                        notes: nil,
                                        dueDate: viewModel.currentDay))
            switch createTaskResult {
            case let .failure(failure):
                popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                return
            case .success:
                break
            }

            popperUpManager.showPopup(
                style: .bottom(title: TasktiveLocale.getText(.NEW_TASK_SAVED), type: .success, description: nil),
                timeout: 2
            )
        }
    }
}

extension TasksScreen {
    final class ViewModel: ObservableObject {
        @Published var newTitle = "" {
            didSet { newTitleDidSet() }
        }

        @Published var currentDay = Date()
        @Published private(set) var currentFocusedTaskID: UUID?
        @Published private(set) var shownTaskDetails: AppTask? {
            didSet { Task { await shownTaskDetailsDidSet() } }
        }

        @Published var showTaskDetailsSheet = false {
            didSet { Task { await showTaskDetailsSheetDidSet() } }
        }

        init() { }

        var disableNewTaskSubmitButton: Bool {
            invalidTitle
        }

        @MainActor
        func setCurrentFocusedTaskID(_ id: UUID?) {
            guard currentFocusedTaskID != id else { return }

            withAnimation {
                currentFocusedTaskID = id
            }
        }

        func showDetailsSheet(for task: AppTask) async {
            await setShownTaskDetails(task)
        }

        func closeDetailsSheet() async {
            await setShownTaskDetails(nil)
        }

        func goToToday() async {
            let now = Date()
            guard !currentDay.isSameDay(as: now) else { return }
            await setCurrentDay(now)
            await setCurrentFocusedTaskID(nil)
        }

        func goToPreviousDay() async {
            let previousDate = incrementDay(of: currentDay, by: -1)
            await setCurrentDay(previousDate)
            await setCurrentFocusedTaskID(nil)
        }

        func goToNextDay() async {
            let previousDate = incrementDay(of: currentDay, by: 1)
            await setCurrentDay(previousDate)
            await setCurrentFocusedTaskID(nil)
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
            date.incrementByDays(increment)
        }

        private func newTitleDidSet() { }

        private func shownTaskDetailsDidSet() async {
            await setShowTaskDetailsSheet(shownTaskDetails != nil)
        }

        private func showTaskDetailsSheetDidSet() async {
            if !showTaskDetailsSheet {
                await setShownTaskDetails(nil)
            }
        }

        @MainActor
        private func setShownTaskDetails(_ task: AppTask?) {
            shownTaskDetails = task
        }

        @MainActor
        private func setShowTaskDetailsSheet(_ state: Bool) {
            guard showTaskDetailsSheet != state else { return }

            showTaskDetailsSheet = state
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
                return TasktiveLocale.getText(.INVALID_TITLE_ERROR_TITLE)
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
