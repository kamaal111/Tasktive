//
//  Remindable.swift
//
//
//  Created by Kamaal M Farah on 10/10/2022.
//

import Foundation

/// Protocol to help to conform by a "Reminder".
public protocol Remindable {
    /// ID of the reminder.
    var id: UUID { get }
    /// When to send out the reminder.
    var time: Date { get }
    /// Creation date of a reminder.
    var creationDate: Date { get }
    /// Data source of the reminder.
    var source: DataSource { get }
}

extension Remindable {
    /// App reminder representation of the reminder.
    public var toAppReminder: AppReminder {
        .init(id: id, time: time, creationDate: creationDate, source: source)
    }
}
