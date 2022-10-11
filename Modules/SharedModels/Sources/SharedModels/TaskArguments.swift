//
//  TaskArguments.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Foundation

/// Object to be used to create and/or update a task.
public struct TaskArguments: Equatable, Hashable {
    /// Title of the task.
    public var title: String
    /// Description of the task.
    public let taskDescription: String?
    /// Notes on a task.
    public let notes: String?
    /// Due date on a task.
    public var dueDate: Date
    /// Ticked state on a task.
    public let ticked: Bool
    /// Completion date on a task.
    public let completionDate: Date?
    /// ID of the task.
    public let id: UUID?
    /// Task reminders.
    public var reminders: [ReminderArguments]

    /// Memberwise initializer.
    /// - Parameters:
    ///   - title: Title of the task.
    ///   - taskDescription: Description of the task.
    ///   - notes: Notes on a task.
    ///   - dueDate: Due date on a task.
    ///   - ticked: Ticked state on a task.
    ///   - reminders: Task reminders.
    public init(
        title: String,
        taskDescription: String?,
        notes: String?,
        dueDate: Date,
        ticked: Bool,
        reminders: [ReminderArguments]
    ) {
        self.init(
            title: title,
            taskDescription: taskDescription,
            notes: notes,
            dueDate: dueDate,
            ticked: ticked,
            id: nil,
            completionDate: nil,
            reminders: reminders
        )
    }

    /// Memberwise initializer.
    /// - Parameters:
    ///   - title: Title of the task.
    ///   - taskDescription: Description of the task.
    ///   - notes: Notes on a task.
    ///   - dueDate: Due date on a task.
    ///   - reminders: Task reminders.
    public init(
        title: String,
        taskDescription: String?,
        notes: String?,
        dueDate: Date,
        reminders: [ReminderArguments]
    ) {
        self.init(
            title: title,
            taskDescription: taskDescription,
            notes: notes,
            dueDate: dueDate,
            ticked: false,
            reminders: reminders
        )
    }

    /// Memberwise initializer.
    /// - Parameters:
    ///   - title: Title of the task.
    ///   - taskDescription: Description of the task.
    ///   - notes: Notes on a task.
    ///   - dueDate: Due date on a task.
    ///   - ticked: Ticked state on a task.
    ///   - id: ID of the task.
    ///   - completionDate: Completion date on a task.
    ///   - reminders: Task reminders.
    public init(
        title: String,
        taskDescription: String?,
        notes: String?,
        dueDate: Date,
        ticked: Bool,
        id: UUID?,
        completionDate: Date?,
        reminders: [ReminderArguments]
    ) {
        self.title = title
        self.taskDescription = taskDescription
        self.notes = notes
        self.dueDate = dueDate
        self.ticked = ticked
        self.id = id
        self.completionDate = completionDate
        self.reminders = reminders
    }
}
