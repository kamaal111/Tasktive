//
//  NamiNavigator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI

private let STARTING_SCREEN: NamiNavigator.Screens = .today
private let UNVIEWED_NAVIGATION_PATH = NavigationPath()

final class NamiNavigator: ObservableObject {
    @Published var tabSelection: Screens {
        didSet {
            if navigationPaths[tabSelection] == nil {
                navigationPaths[tabSelection] = NavigationPath()
            }
        }
    }

    @Published var navigationPaths: [Screens: NavigationPath]

    init() {
        self.tabSelection = STARTING_SCREEN
        self.navigationPaths = [STARTING_SCREEN: NavigationPath()]
    }

    var tabs: [Screens] {
        NamiNavigator.Screens
            .allCases
            .filter(\.isTab)
    }

    func screenPath(_ screen: Screens) -> Binding<NavigationPath> {
        Binding(
            get: { self.navigationPaths[screen] ?? UNVIEWED_NAVIGATION_PATH },
            set: { self.navigationPaths[screen] = $0 }
        )
    }
}

extension NamiNavigator {
    enum Screens: Int, Hashable, CaseIterable {
        case today = 0

        var tag: Int {
            rawValue
        }

        var isTab: Bool {
            switch self {
            case .today:
                return true
            }
        }

        var title: String {
            switch self {
            case .today:
                return "Today"
            }
        }

        var icon: String {
            switch self {
            case .today:
                return "doc.text.image"
            }
        }
    }
}
