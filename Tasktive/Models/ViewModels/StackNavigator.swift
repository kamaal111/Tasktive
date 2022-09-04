//
//  StackNavigator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 27/08/2022.
//

import SwiftUI

final class StackNavigator: ObservableObject {
    @Published var path = NavigationPath()
    @Published private(set) var screen: NamiNavigator.Screens

    private let logger = Logster(from: StackNavigator.self)

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
    func navigate<T: Codable & Hashable & Navigatable>(to screen: T) throws {
        guard try shouldNavigate(to: screen) else { return }

        path.append(screen)
    }

    @MainActor
    func goBack() {
        path.removeLast()
    }

    private func shouldNavigate<T: Codable & Hashable & Navigatable>(to screen: T) throws -> Bool {
        guard let lastPathDictionary = try path.asDictionaryArray?.last,
              let lastPathItem = lastPathDictionary.first,
              lastPathItem.key == screen.pathKey else { return true }

        return try screen.shouldNavigate(pathItem: lastPathItem)
    }

    private func clearPath() async {
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
                DispatchQueue.main.async { [weak self] in
                    // Who cares if this crashes in debug mode? You're the developer just fix it
                    // swiftlint:disable force_try
                    try! self!.navigate(to: StackNavigator.Screens.playground)
                }
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

@available(macOS 13.0, iOS 16, *)
extension StackNavigator {
    #if DEBUG
    enum Screens: Int, Hashable, Codable, CaseIterable, Navigatable {
        case playground = 420
        case appLogoCreator = 421
        case coreDataViewer = 422
        case cloudKitDataViewer = 423

        var title: String {
            switch self {
            case .playground:
                return "Playground"
            case .appLogoCreator:
                return "App logo creator"
            case .coreDataViewer:
                return "Core Data viewer"
            case .cloudKitDataViewer:
                return "Cloud Kit data viewer"
            }
        }

        var pathKey: String {
            "Tasktive.StackNavigator.Screens"
        }

        func shouldNavigate(pathItem: Dictionary<String, String>.Element) throws -> Bool {
            guard let screenNumber = Int(pathItem.value),
                  let stackNavigatorScreen = Self(rawValue: screenNumber) else { return false }
            return self != stackNavigatorScreen
        }
    }
    #endif
}
