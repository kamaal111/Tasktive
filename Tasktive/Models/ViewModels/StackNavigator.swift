//
//  StackNavigator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 06/08/2022.
//

import SwiftUI

private let logger = Logster(from: StackNavigator.self)

final class StackNavigator: ObservableObject {
    @Published var path = NavigationPath() {
        didSet {
            logger.info("current path is \(path)")
        }
    }

    init() { }

    @MainActor
    func navigate<T: Codable & Hashable>(to screen: T) {
        path.append(screen)
    }

    func clearPath() async {
        var path = path
        while !path.isEmpty {
            path.removeLast()
        }
        await setPath(path)
    }

    @MainActor
    private func setPath(_ path: NavigationPath) {
        self.path = path
    }
}
