//
//  NamiNavigator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import TasktiveLocale

private let STARTING_SCREEN: NamiNavigator.Screens = .tasks
private let logger = Logster(from: NamiNavigator.self)

final class NamiNavigator: ObservableObject {
    @Published var tabSelection: Screens
    @Published var sidebarSelection: Screens?

    init() {
        self.tabSelection = STARTING_SCREEN
        self.sidebarSelection = STARTING_SCREEN
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
