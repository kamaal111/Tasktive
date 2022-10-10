//
//  AppReminder.swift
//
//
//  Created by Kamaal M Farah on 10/10/2022.
//

import CloudKit
import Foundation

/// Reminder object.
public struct AppReminder: Hashable, Identifiable {
    /// ID of the reminder.
    public let id: UUID
    /// When to send out the reminder.
    public let time: Date
    /// Creation date of a reminder.
    public let creationDate: Date
    /// Data source of the reminder.
    public let source: DataSource
    /// If this object is from iCloud it will have this property set.
    public var record: CKRecord?

    /// Memberwise initializer
    /// - Parameters:
    ///   - id: ID of the reminder.
    ///   - time: When to send out the reminder.
    ///   - creationDate: Creation date of a reminder.
    ///   - source: Data source of the reminder.
    ///   - record: If this object is from iCloud it will have this property set.
    public init(id: UUID, time: Date, creationDate: Date, source: DataSource, record _: CKRecord? = nil) {
        self.id = id
        self.time = time
        self.creationDate = creationDate
        self.source = source
    }
}
