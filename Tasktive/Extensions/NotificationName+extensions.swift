//
//  NotificationName+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 16/07/2022.
//

import Foundation

extension Notification.Name {
    static let navigateToPlayground = makeNotificationName(withKey: "navigate_to_playground")
    static let currentScreenChanged = makeNotificationName(withKey: "current_screen_changed")

    private static func makeNotificationName(withKey key: String) -> Notification.Name {
        Notification.Name("\(Constants.bundleIdentifier).notifications.\(key)")
    }
}
