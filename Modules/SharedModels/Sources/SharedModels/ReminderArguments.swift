//
//  ReminderArguments.swift
//
//
//  Created by Kamaal M Farah on 10/10/2022.
//

import Foundation

/// Object to be used to create and/or update a reminders.
public struct ReminderArguments: Equatable {
    /// When to send a reminder.
    public let time: Date

    /// Memberwise initializer.
    /// - Parameters:
    ///   - time: When to send a reminder.
    public init(time: Date) {
        self.time = time
    }
}
