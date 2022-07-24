//
//  CoreTask+CRUD.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import CoreData
import Foundation
import ShrimpExtensions

private let logger = Logster(from: CoreTask.self)

extension CoreTask: Crudable {
    typealias ReturnType = CoreTask
    typealias Context = NSManagedObjectContext

    var arguments: Arguments {
        .init(title: title, taskDescription: taskDescription, notes: notes, dueDate: dueDate, ticked: ticked)
    }

    func update(with arguments: Arguments) -> Result<CoreTask, CrudErrors> {
        guard let context = managedObjectContext else {
            let message = "Context missing"
            logger.warning(message)
            return .failure(.generalFailure(message: message))
        }

        let updatedTask = updateValues(with: arguments)

        return CoreTask.save(from: context)
            .map {
                updatedTask
            }
    }

    func delete() -> Result<Void, CrudErrors> {
        guard let context = managedObjectContext else {
            let message = "Context missing"
            logger.warning(message)
            return .failure(.generalFailure(message: message))
        }

        context.delete(self)

        return .success(())
    }

    static func create(with arguments: Arguments,
                       from context: NSManagedObjectContext) -> Result<CoreTask, CrudErrors> {
        let newTask = CoreTask(context: context)
            .updateValues(with: arguments)
        newTask.id = arguments.id ?? UUID()
        newTask.creationDate = Date()
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

    static func filter(by predicate: NSPredicate, limit: Int?,
                       from context: NSManagedObjectContext) -> Result<[CoreTask], CrudErrors> {
        let request = request(by: predicate, limit: limit)

        let result: [CoreTask]
        do {
            result = try context.fetch(request)
        } catch {
            logger.error("error while fetching tasks; error=\(error)")
            return .failure(.fetchFailure)
        }

        return .success(result)
    }

    static func updateManyDates(by ids: [UUID], date: Date,
                                on context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        let predicate = NSPredicate(format: "id IN %@", ids.map(\.nsString))
        let request = NSBatchUpdateRequest(entityName: CoreTask.description())
        request.predicate = predicate

        let convertedDate = date as NSDate
        request.propertiesToUpdate = ["dueDate": convertedDate]
        print(ids, date, context)

        do {
            try context.execute(request)
        } catch {
            logger.error("error while updating multiple tasks; error=\(error)")
            return .failure(.updateManyFailure)
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
            logger.error("error while deleting tasks; error=\(error)")
            return .failure(.clearFailure)
        }

        return save(from: context)
    }
    #endif

    struct Arguments: Equatable {
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

    enum CrudErrors: Error {
        case saveFailure
        case fetchFailure
        case clearFailure
        case updateManyFailure
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
            logger.error("error while creating a task; error=\(error)")
            return .failure(.saveFailure)
        }

        return .success(())
    }
}
