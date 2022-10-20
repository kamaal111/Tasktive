//
//  NotificationContent.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/10/2022.
//

import Foundation
import UserNotifications

/// Notification content.
public struct NotificationContent {
    /// Title of the notification.
    public let title: String
    /// Sub title of the notification.
    public let subTitle: String
    /// The category of the notification.
    public let category: Category
    /// The notification sound.
    public let sound: Sound?
    /// Additional data to send with the notification.
    public let data: [String: String]?

    /// Memberwise initializer.
    /// - Parameters:
    ///   - title: Title of the notification.
    ///   - subTitle: Sub title of the notification.
    ///   - category: The category of the notification.
    ///   - sound: The notification sound.
    ///   - data: Additional data to send with the notification.
    public init(
        title: String,
        subTitle: String,
        category: Category,
        sound: Sound? = nil,
        data: [String: String]? = nil
    ) {
        self.title = title
        self.subTitle = subTitle
        self.category = category
        self.sound = sound
        self.data = data
    }

    /// Which sound to use for the notification.
    public enum Sound {
        /// The default notification.
        case `default`

        fileprivate var userNotificationSound: UNNotificationSound {
            switch self {
            case .default:
                return .default
            }
        }
    }

    /// The category of the notification.
    public enum Category: String {
        /// Playground category.
        case playground

        /// Formatted identifier to be passed in to `UNMutableNotificationContent`.
        public var identifier: String {
            "\(Bundle.main.bundleIdentifier!).UserNotification.\(rawValue)"
        }
    }

    var userNotificationContent: UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.categoryIdentifier = category.identifier

        if let data {
            content.userInfo = data
        }

        if let sound {
            content.sound = sound.userNotificationSound
        }

        return content
    }
}
