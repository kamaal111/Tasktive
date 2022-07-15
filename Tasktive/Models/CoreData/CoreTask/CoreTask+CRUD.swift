//
//  CoreTask+CRUD.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import CoreData
import Foundation

private let logger = Logster(from: CoreTask.self)

extension CoreTask: Crudable {
    typealias ReturnType = CoreTask

    static func create(with args: Arguments) -> Result<CoreTask, CrudErrors> {
        guard let context = args.context else { return .failure(.contextMissing) }

        let newTask = CoreTask(context: context)
        newTask.id = UUID()
        newTask.ticked = false
        newTask.title = args.title
        newTask.taskDescription = args.taskDescription
        newTask.notes = args.notes
        newTask.dueDate = args.dueDate

        let now = Date()
        newTask.creationDate = now
        newTask.updateDate = now

        do {
            try context.save()
        } catch {
            logger.error("error while creating a task; error=\(error)")
            return .failure(.saveFailure)
        }

        return .success(newTask)
    }

    struct Arguments {
        let context: NSManagedObjectContext?
        let title: String
        let taskDescription: String?
        let notes: String?
        let dueDate: Date
    }

    enum CrudErrors: Error {
        case contextMissing
        case saveFailure
    }
}
