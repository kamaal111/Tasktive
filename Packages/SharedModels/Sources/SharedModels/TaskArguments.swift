//
//  TaskArguments.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Foundation

public struct TaskArguments: Equatable {
    public var title: String
    public let taskDescription: String?
    public let notes: String?
    public var dueDate: Date
    public let ticked: Bool
    public let completionDate: Date?
    public let id: UUID?

    public init(title: String, taskDescription: String?, notes: String?, dueDate: Date, ticked: Bool) {
        self.title = title
        self.taskDescription = taskDescription
        self.notes = notes
        self.dueDate = dueDate
        self.ticked = ticked
        self.id = nil
        self.completionDate = nil
    }

    public init(title: String, taskDescription: String?, notes: String?, dueDate: Date) {
        self.init(title: title, taskDescription: taskDescription, notes: notes, dueDate: dueDate, ticked: false)
    }

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
