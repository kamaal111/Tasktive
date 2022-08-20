//
//  StackNavigator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 06/08/2022.
//

import SwiftUI

private let logger = Logster(from: StackNavigator.self)

final class StackNavigator: ObservableObject {
    @Published var path = NavigationPath()
    @Published private(set) var screen: NamiNavigator.Screens

    private let notifications: [Notification.Name] = [
        .navigateToPlayground,
    ]

    init(screen: NamiNavigator.Screens) {
        self.screen = screen

        setupObservers()
    }

    deinit {
        removeObservers()
    }

    @MainActor
    func changeScreen(to screen: NamiNavigator.Screens) async {
        guard self.screen != screen else { return }

        // I know it's not the best user experience to lose state of the path of a stack but currently don't know a way
        // to change "stacks" and keep the path state and not mess everything up.
        await clearPath()
        self.screen = screen
    }

    @MainActor
    func navigate<T: Codable & Hashable>(to screen: T) {
        // - TODO: Check if incoming is same last screen using `path.asDictionaryArray` and not navigate if it's the same screen
        path.append(screen)
    }

    @MainActor
    func goBack() {
        path.removeLast()
    }

    func clearPath() async {
        var path = path
        while !path.isEmpty {
            path.removeLast()
        }
        await setPath(path)
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
        switch notification.name {
        #if DEBUG
        case .navigateToPlayground:
            if let notificationScreen = notification.object as? NamiNavigator.Screens, screen == notificationScreen {
                Task { await navigate(to: StackNavigator.Screens.playground) }
            }
        #endif
        default:
            break
        }
    }

    @MainActor
    private func setPath(_ path: NavigationPath) {
        self.path = path
    }
}

extension StackNavigator {
    #if DEBUG
    enum Screens: Int, Hashable, Codable, CaseIterable {
        case playground = 420
        case appLogoCreator = 421

        var title: String {
            switch self {
            case .playground:
                return "Playground"
            case .appLogoCreator:
                return "App logo creator"
            }
        }
    }
    #endif
}
