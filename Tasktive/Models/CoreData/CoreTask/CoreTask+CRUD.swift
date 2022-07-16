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
    typealias Context = NSManagedObjectContext

    static func create(with args: Arguments, from context: NSManagedObjectContext) -> Result<CoreTask, CrudErrors> {
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

        switch save(from: context) {
        case let .failure(failure):
            return .failure(failure)
        case .success:
            break
        }

        return .success(newTask)
    }

    static func list(from context: NSManagedObjectContext) -> Result<[CoreTask], CrudErrors> {
        let predicate = NSPredicate(value: true)
        let request = request(by: predicate)

        let result: [CoreTask]
        do {
            result = try context.fetch(request)
        } catch {
            logger.error("error while fetching tasks; error=\(error)")
            return .failure(.fetchFailure)
        }

        return .success(result)
    }

    #if DEBUG
    static func clear(from context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        guard let request = request() as? NSFetchRequest<NSFetchRequestResult> else {
            return .failure(.generalFailure(message: "Could not typecast request"))
        }

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
        } catch {
            logger.error("error while deleting tasks; error=\(error)")
            return .failure(.clearFailure)
        }

        return save(from: context)
    }
    #endif

    struct Arguments {
        let title: String
        let taskDescription: String?
        let notes: String?
        let dueDate: Date
    }

    enum CrudErrors: Error {
        case saveFailure
        case fetchFailure
        case clearFailure
        case generalFailure(message: String)
    }
}

extension CoreTask {
    private static func request(by predicate: NSPredicate? = nil) -> NSFetchRequest<CoreTask> {
        let request = NSFetchRequest<CoreTask>(entityName: String(describing: CoreTask.self))
        if let predicate {
            request.predicate = predicate
        }
        return request
    }

    private static func save(from context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        do {
            try context.save()
        } catch {
            logger.error("error while creating a task; error=\(error)")
            return .failure(.saveFailure)
        }

        return .success(())
    }
}
