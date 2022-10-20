//
//  TasksScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import Logster
import SalmonUI
import PopperUp
import Environment
import SharedModels
import TasktiveLocale
import ShrimpExtensions

private let SCREEN: NamiNavigator.Screens = .tasks
private let logger = Logster(from: TasksScreen.self)

struct TasksScreen: View {
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var tasksViewModel: TasksViewModel
    @EnvironmentObject private var popperUpManager: PopperUpManager
    @EnvironmentObject private var deviceModel: DeviceModel
    @EnvironmentObject private var userData: UserData

    @StateObject private var viewModel = ViewModel()

    private let dateDragGesture = DragGesture(minimumDistance: 30, coordinateSpace: .local)

    var body: some View {
        ZStack {
            KScrollableForm {
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
                dataSources: viewModel.dataSources(iCloudSyncingIsEnabledByUser: userData.iCloudSyncingIsEnabled),
                submit: onNewTaskSubmit
            )
            .padding(.horizontal, .medium)
            #if os(macOS)
                .padding(.vertical, .medium)
            #else
                .padding(.vertical, .small)
            #endif
                .background(colorScheme == .dark ? Color.black : .white)
                .frame(maxHeight: viewModel.quickAddViewHeight)
                .ktakeSizeEagerly(alignment: .bottom)
        }
        .sheet(isPresented: $viewModel.showTaskDetailsSheet) {
            TaskDetailsSheet(
                task: viewModel.shownTaskDetails,
                availableSources: dataSources,
                currentDate: viewModel.currentDay,
                onClose: { Task { await viewModel.closeDetailsSheet() } },
                onDone: handleTaskEditedInDetailsSheet
            )
            .accentColor(theme.currentAccentColor(scheme: colorScheme))
            .withPopperUp(popperUpManager)
            #if os(macOS)
                .frame(minWidth: 300, minHeight: 200)
            #endif
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                addTaskButton
            }
            #else
            EditButton()
            addTaskButton
            #endif
        }
        .alert(
            tasksViewModel.pendingUserError?.title ?? "",
            isPresented: $viewModel.showUserErrorAlert,
            actions: {
                #if os(iOS)
                Button(action: {
                    if let settingsURL = URL(string: "App-prefs:root=CASTLE") {
                        Task { _ = await UIApplication.shared.open(settingsURL) }
                    }
                    viewModel.closeUserErrorAlert()
                }) {
                    Text(localized: .GO_TO_SETTINGS)
                        .foregroundColor(theme.currentAccentColor(scheme: colorScheme))
                }
                #endif
                Button(TasktiveLocale.getText(.CANCEL), role: .cancel) {
                    viewModel.closeUserErrorAlert()
                }
                .foregroundColor(theme.currentAccentColor(scheme: colorScheme))
            }, message: {
                Text(tasksViewModel.pendingUserError?.errorDescription ?? "")
            }
        )
        .onChange(of: viewModel.currentDay, perform: { newValue in
            Task { await tasksViewModel.getTasks(from: dataSources, for: newValue) }
        })
        .onChange(of: deviceModel.isConnectedToNetwork, perform: { newValue in
            showMessageWhenNotConnectedToTheInternet()
            fetchTasksAfterInternetIsAvailable(newValue)
        })
        .onReceive(NotificationCenter.default.publisher(for: .appBecameActive), perform: { _ in
            guard viewModel.loaded else { return }

            logger.info("attempting to get tasks after becoming active")

            Task { await tasksViewModel.getTasks(from: dataSources, for: viewModel.currentDay) }
        })
        .onChange(of: userData.iCloudSyncingIsEnabled, perform: fetchTasksAfterInternetIsAvailable)
        .onChange(of: tasksViewModel.pendingUserError, perform: { newValue in
            guard let error = newValue else { return }

            viewModel.openUserErrorAlert(with: error)
            tasksViewModel.setPendingUserError(.none)
        })
        .onAppear(perform: handleOnAppear)
    }

    private var addTaskButton: some View {
        Button(action: {
            Task { await viewModel.showDetailsSheet(for: .none) }
        }) {
            Image(systemName: "plus")
                .bold()
                .foregroundColor(.accentColor)
        }
    }

    private var dataSources: [DataSource] {
        viewModel.dataSources(
            isConnectedToNetwork: deviceModel.isConnectedToNetwork,
            iCloudSyncingIsEnabledByUser: userData.iCloudSyncingIsEnabled
        )
    }

    private func fetchTasksAfterInternetIsAvailable(_ internetIsAvailable: Bool) {
        if !internetIsAvailable {
            return
        }

        logger.info("fetching after internet is available")
        Task {
            await tasksViewModel.getTasks(from: dataSources, for: viewModel.currentDay)
        }
    }

    private func handleTaskEditedInDetailsSheet(
        _ arguments: TaskArguments?,
        _ reminderTime: Date?,
        _ newSource: DataSource,
        _ isNewTask: Bool
    ) {
        guard let arguments else {
            logger.warning("arguments are missing", "arguments='\(arguments as Any)'")
            return
        }

        Task {
            if isNewTask {
                let created = await createTask(with: arguments, on: newSource)
                if !created {
                    return
                }
            } else {
                guard let task = viewModel.shownTaskDetails else {
                    logger.warning("task are missing", "task='\(viewModel.shownTaskDetails as Any)'")
                    return
                }

                var arguments = arguments
                if let reminderTime {
                    arguments.reminders = [
                        .init(time: reminderTime, id: task.remindersArray.first?.id, taskID: task.id),
                    ]
                } else {
                    arguments.reminders = []
                }

                let result = await tasksViewModel.updateTask(task, with: arguments, on: newSource)
                switch result {
                case let .failure(failure):
                    popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                    return
                case .success:
                    break
                }
            }

            await viewModel.closeDetailsSheet()
        }
    }

    private func showMessageWhenNotConnectedToTheInternet() {
        guard Environment.Features.iCloudSyncing, !deviceModel.isConnectedToNetwork else { return }

        popperUpManager.showPopup(
            style: .hud(
                title: TasktiveLocale.getText(.NO_CONNECTION),
                systemImageName: "antenna.radiowaves.left.and.right.slash",
                description: nil
            ),
            timeout: 5
        )
    }

    private func handleOnAppear() {
        if viewModel.currentSource == .iCloud,
           !userData.iCloudSyncingIsEnabled || !Environment.Features.iCloudSyncing {
            viewModel.currentSource = .coreData
        }

        Task {
            let result = await tasksViewModel.getInitialTasks(from: dataSources)
            switch result {
            case let .failure(failure):
                popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
                return
            case .success:
                break
            }

            showMessageWhenNotConnectedToTheInternet()
            viewModel.indicateThatViewModelHasLoaded()
        }
    }

    private func onNewTaskSubmit() {
        logger.info("submitting new task")

        Task {
            let created = await createTask(with: viewModel.taskArguments, on: viewModel.currentSource)

            if created {
                viewModel.clearQuickAddInput()
            }
        }
    }

    private func createTask(with arguments: TaskArguments, on newSource: DataSource) async -> Bool {
        let createTaskResult = await tasksViewModel.createTask(with: arguments, on: newSource)
        switch createTaskResult {
        case let .failure(failure):
            popperUpManager.showPopup(style: failure.style, timeout: failure.timeout)
            return false
        case .success:
            break
        }

        popperUpManager.showPopup(
            style: .bottom(title: TasktiveLocale.getText(.NEW_TASK_SAVED), type: .success, description: nil),
            timeout: 2
        )
        return true
    }

    final class ViewModel: ObservableObject {
        @Published var newTitle = ""
        @Published var currentDay = Date()
        @Published private(set) var currentFocusedTaskID: UUID?
        @Published private(set) var shownTaskDetails: AppTask?
        @Published var showTaskDetailsSheet = false
        @Published var showUserErrorAlert = false
        @Published private(set) var loaded = false
        @Published var currentSource = UserDefaults.lastChosenDataSource ?? .coreData {
            didSet { currentSourceDidSet() }
        }

        @Published private(set) var pendingUserError: TasksViewModel.UserErrors? {
            didSet {
                showUserErrorAlert = pendingUserError != nil
            }
        }

        let quickAddViewHeight: CGFloat = 50

        init() { }

        var taskArguments: TaskArguments {
            .init(title: newTitle, taskDescription: nil, notes: nil, dueDate: currentDay, reminders: [])
        }

        @MainActor
        func indicateThatViewModelHasLoaded() {
            loaded = true
        }

        @MainActor
        func openUserErrorAlert(with error: TasksViewModel.UserErrors) {
            pendingUserError = error
        }

        @MainActor
        func closeUserErrorAlert() {
            pendingUserError = nil
        }

        func dataSources(iCloudSyncingIsEnabledByUser: Bool) -> [DataSource] {
            dataSources(isConnectedToNetwork: true, iCloudSyncingIsEnabledByUser: iCloudSyncingIsEnabledByUser)
        }

        func dataSources(isConnectedToNetwork: Bool, iCloudSyncingIsEnabledByUser: Bool) -> [DataSource] {
            DataSource
                .allCases
                .filter { source in
                    if !source.isSupported {
                        return false
                    }

                    if source.requiresInternet, !isConnectedToNetwork {
                        return false
                    }

                    if source == .iCloud, !iCloudSyncingIsEnabledByUser {
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

        func showDetailsSheet(for task: AppTask?) async {
            await setShownTaskDetails(task)
            await setShowTaskDetailsSheet(true)
        }

        func closeDetailsSheet() async {
            await setShownTaskDetails(nil)
            await setShowTaskDetailsSheet(false)
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

        @MainActor
        func clearQuickAddInput() {
            newTitle = ""
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
