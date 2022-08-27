//
//  StackNavigator+14.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 27/08/2022.
//

#if swift(<5.7)
import SwiftUI

private let logger = Logster(from: StackNavigator.self)

final class StackNavigator: ObservableObject {
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

        self.screen = screen
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
                // Who cares if this crashes in debug mode? You're the developer just fix it
                // TODO: NAVIGATE SOMEHOW
//                Task { try! await navigate(to: StackNavigator.Screens.playground) }
            }
        #endif
        default:
            break
        }
    }
}
#endif
