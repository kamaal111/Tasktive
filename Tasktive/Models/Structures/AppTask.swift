//
//  AppTask.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import Foundation

struct AppTask: Hashable, Identifiable, Taskable {
    var id: UUID
    var title: String
    var taskDescription: String?
    var notes: String?
    var ticked: Bool
    var dueDate: Date
    var source: TaskSource

    init(
        id: UUID,
        title: String,
        taskDescription: String? = nil,
        notes: String? = nil,
        ticked: Bool,
        dueDate: Date,
        source: TaskSource
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.notes = notes
        self.ticked = ticked
        self.dueDate = dueDate
        self.source = source
    }
}
