//
//  TaskArguments.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Foundation

/// Object to be used to create and/or update a task.
public struct TaskArguments: Equatable {
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

    /// Memberwise initializer.
    /// - Parameters:
    ///   - title: Title of the task.
    ///   - taskDescription: Description of the task.
    ///   - notes: Notes on a task.
    ///   - dueDate: Due date on a task.
    ///   - ticked: Ticked state on a task.
    public init(title: String, taskDescription: String?, notes: String?, dueDate: Date, ticked: Bool) {
        self.title = title
        self.taskDescription = taskDescription
        self.notes = notes
        self.dueDate = dueDate
        self.ticked = ticked
        self.id = nil
        self.completionDate = nil
    }

    /// Memberwise initializer.
    /// - Parameters:
    ///   - title: Title of the task.
    ///   - taskDescription: Description of the task.
    ///   - notes: Notes on a task.
    ///   - dueDate: Due date on a task.
    public init(title: String, taskDescription: String?, notes: String?, dueDate: Date) {
        self.init(title: title, taskDescription: taskDescription, notes: notes, dueDate: dueDate, ticked: false)
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
    public init(
        title: String,
        taskDescription: String?,
        notes: String?,
        dueDate: Date,
        ticked: Bool,
        id: UUID,
        completionDate: Date?
    ) {
        self.title = title
        self.taskDescription = taskDescription
        self.notes = notes
        self.dueDate = dueDate
        self.ticked = ticked
        self.id = id
        self.completionDate = completionDate
    }
}
