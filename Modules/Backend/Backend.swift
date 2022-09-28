//
//  Backend.swift
//  Backend
//
//  Created by Kamaal M Farah on 28/09/2022.
//

import Skypiea
import Foundation

public class Backend {
    public let tasks: TasksClient
    public let notifications: NotificationsClient

    public init(preview: Bool = false) {
        self.tasks = .init(preview: preview)
        self.notifications = .init(preview: preview)
    }
}
