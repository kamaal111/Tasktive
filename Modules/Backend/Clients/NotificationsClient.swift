//
//  NotificationsClient.swift
//  Backend
//
//  Created by Kamaal M Farah on 29/09/2022.
//

import Skypiea
import Foundation
import UserNotifications

/// The notifications client.
public class NotificationsClient {
    private var _isAuthorized = false
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

    /// Whether user has authorized user notifications or not.
    public var isAuthorized: Bool {
        _isAuthorized
    }

    /// Authorize user notifications.
    public func authorize() async throws -> Bool {
        guard !preview else { return true }

        let options: UNAuthorizationOptions = [.sound, .badge, .alert]
        let authorized = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        _isAuthorized = authorized

        return authorized
    }

    /// Subscribe to all notifications.
    public func subscribeToAll() async throws {
        guard !preview else { return }

        try await skypiea.subscripeToAll()
    }
}
