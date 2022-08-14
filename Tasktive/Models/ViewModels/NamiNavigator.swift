//
//  NamiNavigator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import TasktiveLocale

let STARTING_SCREEN: NamiNavigator.Screens = .tasks
private let logger = Logster(from: NamiNavigator.self)

final class NamiNavigator: ObservableObject {
    @Published var tabSelection: Screens
    #if DEBUG
    @Published var sidebarSelection: Screens?
    #else
    @Published private(set) var sidebarSelection: Screens?
    #endif
    @Published private(set) var pendingSidebarSelection: Screens?

    private var needsToNavigate = false
    private let notifications: [Notification.Name] = [
        .navigateToPlayground,
    ]

    init() {
        self.tabSelection = STARTING_SCREEN
        self.sidebarSelection = STARTING_SCREEN

        setupObservers()
    }

    deinit {
        removeObservers()
    }

    var currentSelection: NamiNavigator.Screens {
        if DeviceModel.deviceType.shouldHaveSidebar {
            return sidebarSelection ?? STARTING_SCREEN
        }
        return tabSelection
    }

    var tabs: [Screens] {
        NamiNavigator.Screens
            .allCases
            .filter(\.isTab)
    }

    var sidebarButtons: [Screens] {
        NamiNavigator.Screens
            .allCases
            .filter(\.isSidebarButton)
    }

    func clearToNavigate() async {
        guard needsToNavigate else { return }

        needsToNavigate = false
        await setSidebarSelection(pendingSidebarSelection)
        await setPendingSidebarSelection(.none)
    }

    func navigate(to screen: Screens?) async {
        if DeviceModel.deviceType.shouldHaveSidebar {
            await navigateOnSidebar(to: screen)
        } else {
            guard let screen = screen else { return }
            await setTabSelection(screen)
        }
    }

    @MainActor
    func setSidebarSelection(_ selection: Screens?) {
        sidebarSelection = selection
    }

    @MainActor
    func setTabSelection(_ selection: Screens) {
        tabSelection = selection
    }

    @MainActor
    private func navigateOnSidebar(to screen: Screens?) {
        guard screen != sidebarSelection else { return }

        needsToNavigate = true
        setPendingSidebarSelection(screen)
    }

    @MainActor
    private func setPendingSidebarSelection(_ selection: Screens?) {
        pendingSidebarSelection = selection
    }

    private func setupObservers() {
        notifications.forEach { notification in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNotification),
                name: notification,
                object: .none
            )
        }
    }

    private func removeObservers() {
        notifications.forEach { notification in
            NotificationCenter.default.removeObserver(self, name: notification, object: .none)
        }
    }

    @objc
    private func handleNotification(_ notification: Notification) {
        let name = notification.name
        switch name {
        default:
            break
        }
    }
}

extension NamiNavigator {
    enum Screens: Int, Hashable, Codable, CaseIterable {
        case tasks = 0
        case settings = 1

        var tag: Int {
            rawValue
        }

        var isTab: Bool {
            switch self {
            case .tasks, .settings:
                return true
            }
        }

        var isSidebarButton: Bool {
            switch self {
            case .tasks, .settings:
                return true
            }
        }

        var title: String {
            switch self {
            case .tasks:
                return TasktiveLocale.getText(.TASKS)
            case .settings:
                return TasktiveLocale.getText(.SETTINGS)
            }
        }

        var icon: String {
            switch self {
            case .tasks:
                return "doc.text.image"
            case .settings:
                return "gearshape"
            }
        }
    }
}
