//
//  Taskable.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Foundation

/// Protocol to help to conform by a "Task".
public protocol Taskable {
    /// ID of the task.
    var id: UUID { get }
    /// Title of the task.
    var title: String { get }
    /// Description of the task.
    var taskDescription: String? { get }
    /// Notes on a task.
    var notes: String? { get }
    /// Ticked state on a task.
    var ticked: Bool { get }
    /// Due date on a task.
    var dueDate: Date { get }
    /// Completion date on a task.
    var completionDate: Date? { get }
    /// Creation date of a task.
    var creationDate: Date { get }
    /// Data source of the task.
    var source: DataSource { get }
}

extension Taskable {
    /// App task representation of the task.
    public var asAppTask: AppTask {
        .init(
            id: id,
            title: title,
            ticked: ticked,
            dueDate: dueDate,
            completionDate: completionDate,
            creationDate: creationDate,
            source: source
        )
    }
}
