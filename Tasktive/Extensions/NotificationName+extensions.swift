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
    static let iCloudChanges = makeNotificationName(withKey: "icloud_changes")
    static let changeEditMode = makeNotificationName(withKey: "change_edit_mode")
    static let appBecameActive = makeNotificationName(withKey: "app_became_active")
    static let navigateToTasksDueDate = makeNotificationName(withKey: "navigate_to_tasks_due_date")
    /// What happens if you shake your mac? 😋
    static let deviceDidShake = makeNotificationName(withKey: "device_did_shake")

    private static func makeNotificationName(withKey key: String) -> Notification.Name {
        Notification.Name("\(Constants.bundleIdentifier).notifications.\(key)")
    }
}
