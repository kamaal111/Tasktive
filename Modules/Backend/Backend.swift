//
//  Backend.swift
//  Backend
//
//  Created by Kamaal M Farah on 28/09/2022.
//

import Skypiea
import Foundation

/// Data handler.
public class Backend {
    /// Tasks client.
    public let tasks: TasksClient
    /// Notifications client.
    public let notifications: NotificationsClient

    /// Initialize ``Backend`` in preview mode or not.
    /// - Parameter preview: Whether to turn on preview mode or not.
    public init(preview: Bool = false) {
        self.tasks = .init(preview: preview)
        self.notifications = .init(preview: preview)
    }
}
