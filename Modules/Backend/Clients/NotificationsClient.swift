//
//  NotificationsClient.swift
//  Backend
//
//  Created by Kamaal M Farah on 29/09/2022.
//

import Skypiea
import Logster
import Foundation
import SharedModels
import UserNotifications

private let logger = Logster(from: NotificationsClient.self)

/// The notifications client.
public class NotificationsClient {
    private var _isAuthorized = false
    private let userNotificationCenter: UNUserNotificationCenter = .current()
    private let skypiea: Skypiea
    private let preview: Bool

    /// Initialize ``Backend`` in preview mode or not.
    /// - Parameter preview: Whether to turn on preview mode or not.
    public init(preview: Bool) {
        if !preview {
            self.skypiea = .shared
        } else {
            self.skypiea = .preview
        }
        self.preview = preview
    }

    // - MARK: Errors

    public enum Errors: Error {
        case unauthorizedToRecieveNotifications(context: Error?)
        case failedToSchedule(context: Error?)
    }

    /// Whether user has authorized user notifications or not.
    public var isAuthorized: Bool {
        _isAuthorized
    }

    /// Authorize user notifications.
    public func authorize() async throws -> Bool {
        guard !preview else { return true }

        let options: UNAuthorizationOptions = [.sound, .badge, .alert]
        let authorized = try await userNotificationCenter.requestAuthorization(options: options)
        _isAuthorized = authorized

        return authorized
    }

    /// Schedule a notification.
    /// - Parameters:
    ///   - content: notification content.
    ///   - date: for when to schedule the notification for.
    ///   - identifier: Identifier of reminder.
    /// - Returns: a result returning nothing (Void) on success and ``Errors`` on failure.
    public func schedule(
        _ content: NotificationContent,
        for date: Date,
        identifier: UUID
    ) async -> Result<Void, Errors> {
        if !isAuthorized {
            let isAuthorized: Bool
            do {
                isAuthorized = try await authorize()
            } catch {
                return .failure(.unauthorizedToRecieveNotifications(context: error))
            }

            if !isAuthorized {
                return .failure(.unauthorizedToRecieveNotifications(context: .none))
            }
        }

        var triggerTime = abs(date.timeIntervalSince(Date()))
        if triggerTime <= 5 {
            triggerTime = 5
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier.uuidString,
            content: content.userNotificationContent,
            trigger: trigger
        )

        do {
            try await userNotificationCenter.add(request)
        } catch {
            return .failure(.failedToSchedule(context: error))
        }

        logger.info("scheduled notification for in \(triggerTime) seconds",
                    "id='\(identifier.uuidString)'",
                    "category='\(content.category.identifier)'")

        return .success(())
    }

    /// Cancel a pending notification.
    /// - Parameter identifier: The notification identifier to delete.
    public func cancel(identifier: UUID) {
        logger.info("cancelled scheduled notification with the id \(identifier.uuidString)")

        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier.uuidString])
    }

    /// Subscribe to all notifications.
    public func subscribeToAll() async throws {
        guard !preview else { return }

        try await skypiea.subscripeToAll()
    }
}
