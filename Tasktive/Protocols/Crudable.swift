//
//  Crudable.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import Foundation

protocol Crudable {
    associatedtype ReturnType: Crudable
    associatedtype CrudErrors: Error
    associatedtype Context

    var asAppTask: AppTask { get }

    func update(with arguments: TaskArguments) -> Result<ReturnType, CrudErrors>
    func delete() -> Result<Void, CrudErrors>

    static func create(with arguments: TaskArguments, from context: Context) -> Result<ReturnType, CrudErrors>
    static func list(from context: Context) -> Result<[ReturnType], CrudErrors>
    static func filter(
        by predicate: NSPredicate,
        limit: Int?,
        from context: Context
    ) -> Result<[ReturnType], CrudErrors>
    static func filter(by predicate: NSPredicate, from context: Context) -> Result<[ReturnType], CrudErrors>
}

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
