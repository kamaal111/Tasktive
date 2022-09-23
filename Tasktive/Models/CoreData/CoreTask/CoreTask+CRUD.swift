//
//  CoreTask+CRUD.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import Logster
import CoreData
import Foundation
import ShrimpExtensions

private let logger = Logster(from: CoreTask.self)

extension CoreTask: Crudable {
    var arguments: TaskArguments {
        .init(title: title, taskDescription: taskDescription, notes: notes, dueDate: dueDate, ticked: ticked)
    }

    func update(with arguments: TaskArguments, on context: NSManagedObjectContext) -> Result<CoreTask, CrudErrors> {
        let updatedTask = updateValues(with: arguments)

        return CoreTask.save(from: context)
            .map {
                updatedTask
            }
    }

    func delete(on context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        context.delete(self)

        do {
            try context.save()
        } catch {
            return .failure(.deletionFailure(context: error))
        }

        return .success(())
    }

    static func find(by predicate: NSPredicate, from context: NSManagedObjectContext) -> Result<CoreTask?, CrudErrors> {
        filter(by: predicate, limit: 1, from: context).map(\.first)
    }

    static func create(with arguments: TaskArguments,
                       from context: NSManagedObjectContext) -> Result<CoreTask, CrudErrors> {
        let newTask = CoreTask(context: context)
            .updateValues(with: arguments)
        newTask.id = arguments.id ?? UUID()
        newTask.kCreationDate = Date()
        newTask.attachments = NSSet(array: [])
        newTask.reminders = NSSet(array: [])
        newTask.tags = NSSet(array: [])

        return save(from: context)
            .map {
                newTask
            }
    }

    static func list(from context: NSManagedObjectContext) -> Result<[CoreTask], CrudErrors> {
        let predicate = NSPredicate(value: true)

        return filter(by: predicate, from: context)
    }

    static func filter(by predicate: NSPredicate,
                       from context: NSManagedObjectContext) -> Result<[CoreTask], CrudErrors> {
        filter(by: predicate, limit: nil, from: context)
    }

    static func filter(by predicate: NSPredicate,
                       limit: Int?,
                       from context: NSManagedObjectContext) -> Result<[CoreTask], CrudErrors> {
        let request = request(by: predicate, limit: limit)

        let result: [CoreTask]
        do {
            result = try context.fetch(request)
        } catch {
            logger.error(label: "error while fetching tasks", error: error)
            return .failure(.fetchFailure(context: error))
        }

        return .success(result)
    }

    static func updateManyDates(_ tasks: [AppTask],
                                date: Date,
                                on context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        guard !tasks.isEmpty else { return .success(()) }

        let predicate = NSPredicate(format: "id IN %@", tasks.map(\.id.nsString))
        let request = NSBatchUpdateRequest(entityName: CoreTask.description())
        request.predicate = predicate

        let convertedDate = date as NSDate
        request.propertiesToUpdate = ["dueDate": convertedDate]

        do {
            try context.execute(request)
        } catch {
            logger.error(label: "error while updating multiple tasks", error: error)
            return .failure(.updateManyFailure(context: error))
        }

        return .success(())
    }

    #if DEBUG
    static func clear(from context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        guard let request = request() as? NSFetchRequest<NSFetchRequestResult> else {
            let message = "Could not typecast request"
            logger.warning(message)
            return .failure(.generalFailure(message: message))
        }

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
        } catch {
            logger.error(label: "error while deleting tasks", error: error)
            return .failure(.clearFailure(context: error))
        }

        return save(from: context)
    }
    #endif

    enum CrudErrors: Error {
        case saveFailure(context: Error?)
        case fetchFailure(context: Error?)
        case clearFailure(context: Error?)
        case deletionFailure(context: Error?)
        case updateManyFailure(context: Error?)
        case generalFailure(message: String)
    }
}

extension CoreTask {
    private func updateValues(with arguments: TaskArguments) -> CoreTask {
        ticked = arguments.ticked
        title = arguments.title
        taskDescription = arguments.taskDescription
        notes = arguments.notes
        dueDate = arguments.dueDate
        completionDate = arguments.completionDate
        updateDate = Date()

        return self
    }

    private static func request(by predicate: NSPredicate? = nil, limit: Int? = nil) -> NSFetchRequest<CoreTask> {
        let request = NSFetchRequest<CoreTask>(entityName: String(describing: CoreTask.self))
        if let predicate = predicate {
            request.predicate = predicate
        }
        if let limit = limit {
            request.fetchLimit = limit
        }
        return request
    }

    private static func save(from context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        do {
            try context.save()
        } catch {
            logger.error(label: "error while creating a task", error: error)
            return .failure(.saveFailure(context: error))
        }

        return .success(())
    }
}
