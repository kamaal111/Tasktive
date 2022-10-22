//
//  ReminderArguments.swift
//
//
//  Created by Kamaal M Farah on 10/10/2022.
//

import Foundation

/// Object to be used to create and/or update a reminders.
public struct ReminderArguments: Equatable, Hashable {
    /// When to send a reminder.
    public let time: Date
    /// The reminders id, if already set.
    public let id: UUID?
    /// The parent task id.
    public let taskID: UUID?

    /// Memberwise initializer.
    /// - Parameters:
    ///   - time: When to send a reminder.
    ///   - id: The reminders id, if already set.
    ///   - taskID: The parent task id.
    public init(time: Date, id: UUID? = nil, taskID: UUID? = nil) {
        self.time = time
        self.id = id
        self.taskID = taskID
    }
}
