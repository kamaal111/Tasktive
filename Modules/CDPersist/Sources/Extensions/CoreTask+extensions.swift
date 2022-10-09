//
//  CoreTask+extensions.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Logster
import CoreData
import Foundation
import SharedModels

private let logger = Logster(from: CoreTask.self)

extension CoreTask: Crudable, Taskable {
    // - MARK: Crud errors

    /// Errors that can come from `CoreData` operations.
    public enum CrudErrors: Error {
        /// Failure on saving a task.
        case saveFailure(context: Error?)
        /// Failure on fetching tasks.
        case fetchFailure(context: Error?)
        /// Failure on clearing tasks.
        case clearFailure(context: Error?)
        /// Failure on deleting a task.
        case deletionFailure(context: Error?)
        /// Failure on updating many tasks.
        case updateManyFailure(context: Error?)
        /// General failure.
        case generalFailure(message: String)
        /// Failure on creating a reminder.
        case reminderCreationFailure(context: CoreReminder.CrudErrors)
    }

    // - MARK: Helper methods

    /// Alias for ``CoreBase/kCreationDate``.
    public var creationDate: Date {
        get {
            kCreationDate
        }
        set {
            kCreationDate = newValue
        }
    }

    /// Where this object is located, in this in `CoreData`.
    public var source: DataSource {
        .coreData
    }

    /// Arguments to be used to create and/or update a task.
    public var arguments: TaskArguments {
        .init(
            title: title,
            taskDescription: taskDescription,
            notes: notes,
            dueDate: dueDate,
            ticked: ticked,
            id: id,
            completionDate: completionDate
        )
    }

    /// This tasks reminders.
    public var remindersArray: [CoreReminder] {
        reminders?.allObjects as? [CoreReminder] ?? []
    }

    // - MARK: CoreData operations

    /// Set an reminder on this task.
    /// - Parameters:
    ///   - arguments: Arguments to create reminder out of.
    ///   - save: Whether to save or not.
    /// - Returns: A result either containing ``CoreReminder`` on success or ``CrudErrors`` on failure.
    public func setAnReminder(
        with arguments: ReminderArguments,
        save: Bool = true
    ) -> Result<CoreReminder, CrudErrors> {
        guard let context = managedObjectContext else {
            return .failure(.generalFailure(message: "failed to access managed object context on this task"))
        }

        let result = CoreReminder.create(with: arguments, on: context)
        let reminder: CoreReminder
        switch result {
        case let .failure(failure):
            return .failure(.reminderCreationFailure(context: failure))
        case let .success(success):
            reminder = success
        }

        reminder.task = self
        addToReminders(reminder)

        guard save else { return .success(reminder) }

        return Self.save(from: context)
            .map {
                reminder
            }
    }

    /// Update the task.
    /// - Parameters:
    ///   - arguments: The arguments used to update a task.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing ``CoreTask`` on success or ``CrudErrors`` on failure.
    public func update(
        with arguments: TaskArguments,
        on context: NSManagedObjectContext
    ) async -> Result<CoreTask, CrudErrors> {
        let updatedTask = updateValues(with: arguments)

        return CoreTask.save(from: context)
            .map {
                updatedTask
            }
    }

    /// Delete the task.
    /// - Parameter context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing nothing (`Void`) on success or ``CrudErrors`` on failure.
    public func delete(on context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        switch deleteReminders() {
        case let .failure(failure):
            return .failure(failure)
        case .success:
            logger.info("deleted reminders successfully")
        }

        context.delete(self)

        do {
            try context.save()
        } catch {
            return .failure(.deletionFailure(context: error))
        }

        return .success(())
    }

    /// This static method creates a ``CoreTask`` instances and persists in the `CoreData` store.
    /// - Parameters:
    ///   - arguments: Arguments used to create the ``CoreTask`` instance.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing ``CoreTask`` on success or ``CrudErrors`` on failure.
    public static func create(
        with arguments: TaskArguments,
        from context: NSManagedObjectContext
    ) -> Result<CoreTask, CrudErrors> {
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

    /// Find a single task by a predicate.
    /// - Parameters:
    ///   - predicate: Query to find the task.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing an optional ``CoreTask`` on success or ``CrudErrors`` on failure.
    public static func find(
        by predicate: NSPredicate,
        from context: NSManagedObjectContext
    ) -> Result<CoreTask?, CrudErrors> {
        filter(by: predicate, limit: 1, from: context).map(\.first)
    }

    /// List all tasks.
    /// - Parameter context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing an array with all tasks on success or ``CrudErrors`` on failure.
    public static func list(from context: NSManagedObjectContext) -> Result<[CoreTask], CrudErrors> {
        let predicate = NSPredicate(value: true)

        return filter(by: predicate, from: context)
    }

    /// Filtered list of tasks depending on the given predicate query.
    /// - Parameters:
    ///   - predicate: Query to filter the tasks on.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing an array with filtered tasks on success or ``CrudErrors`` on failure.
    public static func filter(
        by predicate: NSPredicate,
        from context: NSManagedObjectContext
    ) -> Result<[CoreTask], CrudErrors> {
        filter(by: predicate, limit: nil, from: context)
    }

    /// Filtered list of tasks depending on the given predicate query.
    /// - Parameters:
    ///   - predicate:  Query to filter the tasks on.
    ///   - limit: The maximum amount of tasks to return.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing an array with filtered tasks on success or ``CrudErrors`` on failure.
    public static func filter(
        by predicate: NSPredicate,
        limit: Int?,
        from context: NSManagedObjectContext
    ) -> Result<[CoreTask], CrudErrors> {
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

    /// Update many tasks ``dueDate`` depending on a certain predicate query.
    /// - Parameters:
    ///   - tasks: The tasks to update.
    ///   - date: What to change the ``dueDate`` to.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing nothing (`Void`) on success or ``CrudErrors`` on failure.
    public static func updateManyDates(
        _ tasks: [AppTask],
        date: Date,
        on context: NSManagedObjectContext
    ) -> Result<Void, CrudErrors> {
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

    // - MARK: Internal properties/methods

    #if DEBUG
    /// To clear all tasks.
    /// - Parameter context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing nothing(`Void`) on success or ``CrudErrors`` on failure.
    public static func clear(from context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        switch CoreReminder.clear(from: context) {
        case let .failure(failure):
            return .failure(.clearFailure(context: failure))
        case .success:
            break
        }

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

    // - MARK: Private properties/methods

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

    private func deleteReminders() -> Result<Void, CrudErrors> {
        guard let context = managedObjectContext else {
            return .failure(.generalFailure(message: "failed to access managed object context on this task"))
        }

        for reminder in remindersArray {
            do {
                try reminder.delete(on: context, save: false).get()
            } catch {
                return .failure(.deletionFailure(context: error))
            }
        }

        return .success(())
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
