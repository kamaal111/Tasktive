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

    func update(with arguments: Arguments) -> Result<CoreTask, CrudErrors> {
        guard let context = managedObjectContext else {
            let message = "Context missing"
            logger.warning(message)
            return .failure(.generalFailure(message: message))
        }

        let updatedTask = updateValues(with: arguments)

        switch CoreTask.save(from: context) {
        case let .failure(failure):
            return .failure(failure)
        case .success:
            break
        }

        return .success(updatedTask)
    }

    static func create(with arguments: Arguments,
                       from context: NSManagedObjectContext) -> Result<CoreTask, CrudErrors> {
        var newTask = CoreTask(context: context)
        newTask.id = UUID()
        newTask.creationDate = Date()

        newTask = newTask.updateValues(with: arguments)

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
            let message = "Could not typecast request"
            logger.warning(message)
            return .failure(.generalFailure(message: message))
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
        let ticked: Bool

        init(title: String, taskDescription: String?, notes: String?, dueDate: Date, ticked: Bool) {
            self.title = title
            self.taskDescription = taskDescription
            self.notes = notes
            self.dueDate = dueDate
            self.ticked = ticked
        }

        init(title: String, taskDescription: String?, notes: String?, dueDate: Date) {
            self.init(title: title, taskDescription: taskDescription, notes: notes, dueDate: dueDate, ticked: false)
        }
    }

    enum CrudErrors: Error {
        case saveFailure
        case fetchFailure
        case clearFailure
        case generalFailure(message: String)
    }
}

extension CoreTask {
    private func updateValues(with arguments: Arguments) -> CoreTask {
        ticked = arguments.ticked
        title = arguments.title
        taskDescription = arguments.taskDescription
        notes = arguments.notes
        dueDate = arguments.dueDate
        updateDate = Date()

        return self
    }

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
