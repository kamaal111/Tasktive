//
//  TaskArguments.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 02/09/2022.
//

import Foundation
import ShrimpExtensions

struct TaskArguments: Equatable {
    var title: String
    let taskDescription: String?
    let notes: String?
    var dueDate: Date
    let ticked: Bool
    let completionDate: Date?
    let id: UUID?

    init(title: String, taskDescription: String?, notes: String?, dueDate: Date, ticked: Bool) {
        self.title = title
        self.taskDescription = taskDescription
        self.notes = notes
        self.dueDate = dueDate
        self.ticked = ticked
        self.id = nil
        self.completionDate = nil
    }

    init(title: String, taskDescription: String?, notes: String?, dueDate: Date) {
        self.init(title: title, taskDescription: taskDescription, notes: notes, dueDate: dueDate, ticked: false)
    }

    init(
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
