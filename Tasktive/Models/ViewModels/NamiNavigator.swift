//
//  NamiNavigator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import TasktiveLocale

private let STARTING_SCREEN: NamiNavigator.Screens = .tasks
private let UNVIEWED_NAVIGATION_PATH = NavigationPath()
private let logger = Logster(from: NamiNavigator.self)

final class NamiNavigator: ObservableObject {
    @Published var tabSelection: Screens {
        didSet {
            if navigationPaths[tabSelection] == nil {
                navigationPaths[tabSelection] = NavigationPath()
            }
        }
    }

    @Published var sidebarSelection: Screens? {
        didSet {
            if let sidebarSelection, navigationPaths[sidebarSelection] == nil {
                navigationPaths[sidebarSelection] = NavigationPath()
            }
        }
    }

    @Published private(set) var navigationPaths: [Screens: NavigationPath] {
        didSet {
            guard let path = navigationPaths[currentScreen] else { return }

            logger.info("current path is \(path)")
        }
    }

    init() {
        self.tabSelection = STARTING_SCREEN
        self.sidebarSelection = STARTING_SCREEN
        self.navigationPaths = [STARTING_SCREEN: NavigationPath()]
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

    @MainActor
    func navigateOnSidebar(to screen: Screens?) {
        guard screen != sidebarSelection else { return }

        sidebarSelection = screen
    }

    func screenPath(_ screen: Screens?) -> Binding<NavigationPath> {
        Binding(
            get: {
                guard let screen else { return UNVIEWED_NAVIGATION_PATH }

                return self.navigationPaths[screen] ?? UNVIEWED_NAVIGATION_PATH
            },
            set: {
                guard let screen else { return }

                self.navigationPaths[screen] = $0
            }
        )
    }

    private var currentScreen: Screens {
        if DeviceModel.deviceType.shouldHaveSidebar {
            return sidebarSelection ?? STARTING_SCREEN
        }

        return tabSelection
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
