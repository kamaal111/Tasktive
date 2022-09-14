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
    @EnvironmentObject private var deviceModel: DeviceModel

    @StateObject private var viewModel = ViewModel()

    private let dateDragGesture = DragGesture(minimumDistance: 30, coordinateSpace: .local)

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
                #if os(iOS)
                .contentShape(Rectangle())
                .gesture(dateDragGesture.onEnded(viewModel.onDateDragGestureEnd))
                #endif

                ProgressSection(
                    currentDate: $viewModel.currentDay,
                    progress: tasksViewModel.progressForDate(viewModel.currentDay)
                )
                #if os(iOS)
                .contentShape(Rectangle())
                .gesture(dateDragGesture.onEnded(viewModel.onDateDragGestureEnd))
                #endif
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
                    onDetailsPress: { task in Task { await viewModel.showDetailsSheet(for: task) } },
                    onDelete: { task in Task { await tasksViewModel.deleteTask(task) } }
                )
                .disabled(tasksViewModel.settingTasks)
                #if os(macOS)
                    .padding(.horizontal, Constants.UI.mainViewHorizontalWidth)
                #endif
            }
            .padding(.bottom, viewModel.quickAddViewHeight)
            .ktakeSizeEagerly(alignment: .topLeading)
            QuickAddSection(
                title: $viewModel.newTitle,
                currentSource: $viewModel.currentSource,
                disableSubmit: viewModel
                    .disableNewTaskSubmitButton(isConnectedToNetwork: deviceModel.isConnectedToNetwork),
                dataSources: viewModel.dataSources,
                submit: onNewTaskSubmit
            )
            .padding(.horizontal, .medium)
            #if os(macOS)
                .padding(.vertical, .medium)
            #else
                .padding(.vertical, .small)
            #endif
                .background(colorScheme == .dark ? Color.black : Color.white)
                .frame(maxHeight: viewModel.quickAddViewHeight)
                .ktakeSizeEagerly(alignment: .bottom)
        }
        .onChange(of: viewModel.currentDay, perform: { newValue in
            Task { await tasksViewModel.getTasks(from: dataSources, for: newValue) }
        })
        .onChange(of: deviceModel.isConnectedToNetwork, perform: { newValue in
            guard newValue else { return }

            // Reconnected to the internet
            Task { await tasksViewModel.getTasks(from: dataSources, for: viewModel.currentDay) }
        })
        .onAppear(perform: handleOnAppear)
        .sheet(isPresented: $viewModel.showTaskDetailsSheet) {
            TaskDetailsSheet(
                task: viewModel.shownTaskDetails,
                onClose: { Task { await viewModel.closeDetailsSheet() } },
                onDone: handleTaskEditedInDetailsSheet(_:),
                onDelete: handleTaskDeletedInDetailsSheet
            )
            .accentColor(theme.currentAccentColor)
            .withPopperUp(popperUpManager)
            #if os(macOS)
                .frame(minWidth: 300, minHeight: 160)
            #endif
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .bold()
            }
            #else
            EditButton()
            #endif
        }
    }

    private var dataSources: [DataSource] {
        viewModel.dataSources(isConnectedToNetwork: deviceModel.isConnectedToNetwork)
    }

    private func handleTaskEditedInDetailsSheet(_ arguments: TaskArguments?) {
        guard let arguments = arguments, let task = viewModel.shownTaskDetails else {
            logger.warning(
                "task or/and arguments are missing",
                "arguments='\(arguments as Any)'",
                "task='\(viewModel.shownTaskDetails as Any)'"
            )
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

    private func handleTaskDeletedInDetailsSheet() {
        guard let task = viewModel.shownTaskDetails else {
            logger.warning("task is missing", "task='\(viewModel.shownTaskDetails as Any)'")
            return
        }

        Task {
            let result = await tasksViewModel.deleteTask(task)
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
            let result = await tasksViewModel.getTodaysTasks(from: dataSources)
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
            let validatedTaskDataResult = await viewModel.validateNewTask()
            let newTitle: String
            switch validatedTaskDataResult {
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
                                        dueDate: viewModel.currentDay),
                            on: viewModel.currentSource)
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

        @Published var currentSource = UserDefaults.lastChosenDataSource ?? .coreData {
            didSet { currentSourceDidSet() }
        }

        var pendingInternetFetch = false
        let quickAddViewHeight: CGFloat = 50

        init() { }

        var dataSources: [DataSource] {
            dataSources(isConnectedToNetwork: true)
        }

        func dataSources(isConnectedToNetwork: Bool) -> [DataSource] {
            DataSource
                .allCases
                .filter { source in
                    if !source.isSupported {
                        return false
                    }

                    if source.requiresInternet, !isConnectedToNetwork {
                        return false
                    }

                    return true
                }
        }

        func disableNewTaskSubmitButton(isConnectedToNetwork: Bool) -> Bool {
            invalidTitle || (!isConnectedToNetwork && currentSource == .iCloud)
        }

        func onDateDragGestureEnd(_ value: DragGesture.Value) {
            switch (value.translation.width, value.translation.height) {
            // when swiping from right to left (without going up or down more than 30px)
            case (...0, -30 ... 30):
                Task { await goToNextDay() }

            // when swiping from left to right (without going up or down more than 30px)
            case (0..., -30 ... 30):
                Task { await goToPreviousDay() }

            default: break
            }
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

        func validateNewTask() async -> Result<String, ValidationErrors> {
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

        private func currentSourceDidSet() {
            UserDefaults.lastChosenDataSource = currentSource
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

#if DEBUG
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
#endif
