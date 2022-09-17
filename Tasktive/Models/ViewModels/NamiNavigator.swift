//
//  NamiNavigator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import Environment
import TasktiveLocale

private let logger = Logster(from: NamiNavigator.self)

final class NamiNavigator: ObservableObject {
    @Published var tabSelection: Screens
    #if DEBUG
    @Published var sidebarSelection: Screens?
    #else
    @Published private(set) var sidebarSelection: Screens?
    #endif

    private var needsToNavigate = false

    init() {
        self.tabSelection = NamiNavigator.STARTING_SCREEN
        self.sidebarSelection = NamiNavigator.STARTING_SCREEN
    }

    var currentSelection: NamiNavigator.Screens {
        if DeviceModel.deviceType.shouldHaveSidebar {
            return sidebarSelection ?? Self.STARTING_SCREEN
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

    func navigate(to screen: Screens?) async {
        if DeviceModel.deviceType.shouldHaveSidebar {
            await navigateOnSidebar(to: screen)
        } else {
            guard let screen = screen else { return }
            await setTabSelection(screen)
        }
    }

    @MainActor
    private func setSidebarSelection(_ selection: Screens?) {
        sidebarSelection = selection
    }

    @MainActor
    private func setTabSelection(_ selection: Screens) {
        tabSelection = selection
    }

    @MainActor
    private func navigateOnSidebar(to screen: Screens?) {
        guard screen != sidebarSelection else { return }

        setSidebarSelection(screen)
    }

    static let STARTING_SCREEN: NamiNavigator.Screens = {
        #if DEBUG
        guard let startingStackScreenValue = Int(Environment.EnvironmentVariables.startingStackScreen.value ?? ""),
              let startingStackScreen = NamiNavigator.Screens(rawValue: startingStackScreenValue) else { return .tasks }

        return startingStackScreen
        #else
            .tasks
        #endif
    }()
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
