//
//  AppTask.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import CloudKit
import Foundation

/// Task object.
public struct AppTask: Hashable, Identifiable {
    /// ID of the task.
    public let id: UUID
    /// Title of the task.
    public var title: String
    /// Description of the task.
    public var taskDescription: String?
    /// Notes on a task.
    public var notes: String?
    /// Ticked state on a task.
    public var ticked: Bool
    /// Due date on a task.
    public var dueDate: Date
    /// Completion date on a task.
    public var completionDate: Date?
    /// Creation date of a task.
    public let creationDate: Date
    /// Data source of the task.
    public let source: DataSource
    /// The tasks reminders.
    public var remindersArray: [AppReminder]
    /// If this object is from iCloud it will have this property set.
    public var record: CKRecord?

    /// Memberwise initializer
    /// - Parameters:
    ///   - id: ID of the task.
    ///   - title: Title of the task.
    ///   - taskDescription: Description of the task.
    ///   - notes: Notes on a task.
    ///   - ticked: Ticked state on a task.
    ///   - dueDate: Due date on a task.
    ///   - completionDate: Completion date on a task.
    ///   - creationDate: Creation date of a task.
    ///   - source: Data source of the task.
    ///   - remindersArray: The tasks reminders.
    ///   - record: If this object is from iCloud it will have this property set.
    public init(
        id: UUID,
        title: String,
        taskDescription: String? = nil,
        notes: String? = nil,
        ticked: Bool,
        dueDate: Date,
        completionDate: Date?,
        creationDate: Date,
        source: DataSource,
        remindersArray: [AppReminder],
        record: CKRecord? = nil
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.notes = notes
        self.ticked = ticked
        self.dueDate = dueDate
        self.completionDate = completionDate
        self.creationDate = creationDate
        self.source = source
        self.remindersArray = remindersArray
        self.record = record
    }

    /// Arguments to be used to create and/or update a task.
    public var arguments: TaskArguments {
        .init(
            title: title,
            taskDescription: taskDescription,
            notes: notes,
            dueDate: dueDate,
            ticked: ticked,
            id: id,
            completionDate: completionDate,
            reminders: remindersArray.map(\.toArguments)
        )
    }

    /// Arguments with ``ticked`` state toggled.
    /// - Parameter newTickState: New tick state.
    /// - Returns: Arguments with ``ticked`` state toggled.
    public func toggleCoreTaskTickArguments(with newTickState: Bool) -> TaskArguments {
        .init(
            title: title,
            taskDescription: taskDescription,
            notes: notes,
            dueDate: dueDate,
            ticked: newTickState,
            id: id,
            completionDate: newTickState ? Date() : nil,
            reminders: remindersArray.map(\.toArguments)
        )
    }
}
