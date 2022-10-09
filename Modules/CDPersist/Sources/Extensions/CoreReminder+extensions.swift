//
//  CoreReminder+extensions.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 09/10/2022.
//

import Logster
import CoreData
import Foundation
import SharedModels
import ShrimpExtensions

private let logger = Logster(from: CoreReminder.self)

extension CoreReminder {
    // - MARK: Crud errors

    /// Errors that can come from `CoreData` operations.
    public enum CrudErrors: Error {
        /// Failure on saving a reminder.
        case saveFailure(context: Error)
        /// Failure on deleting a reminder.
        case deletionFailure(context: Error)
        /// General failure.
        case generalFailure(message: String)
        /// Failure on clearing tasks.
        case clearFailure(context: Error)
        /// Failure on fetching tasks.
        case fetchFailure(context: Error)
    }

    // - MARK: Helper methods

    /// Arguments to be used to create and/or update a reminder.
    public var arguments: ReminderArguments {
        .init(time: time)
    }

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

    // - MARK: CoreData operations

    /// Delete this reminder.
    /// - Parameters:
    ///   - context: The context to use to operate the `CoreData` operation.
    ///   - save: Whether to save or not
    /// - Returns: A result either containing nothing (`Void`) on success or ``CrudErrors`` on failure.
    public func delete(on context: NSManagedObjectContext, save: Bool = false) -> Result<Void, CrudErrors> {
        context.delete(self)

        if save {
            do {
                try context.save()
            } catch {
                return .failure(.deletionFailure(context: error))
            }
        }

        var taskReminders = task.remindersArray
        if let index = taskReminders.findIndex(by: \.id, is: id) {
            taskReminders.remove(at: index)
            task.reminders = taskReminders.asNSSet
        }

        return .success(())
    }

    /// This static method creates a ``CoreReminder`` instance and persists it in the `CoreData` store.
    /// - Parameters:
    ///   - arguments: Arguments used to create the ``CoreReminder`` instance.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing ``CoreReminder`` on success or ``CrudErrors`` on failure.
    public static func create(
        with arguments: ReminderArguments,
        on context: NSManagedObjectContext
    ) -> Result<CoreReminder, CrudErrors> {
        let newReminder = CoreReminder(context: context)
            .updateValues(with: arguments)

        newReminder.id = UUID()
        newReminder.kCreationDate = Date()

        return .success(newReminder)
    }

    /// Find a single reminder by a predicate.
    /// - Parameters:
    ///   - predicate: Query to find the task.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing an optional ``CoreReminder`` on success or ``CrudErrors`` on failure.
    public static func find(
        by predicate: NSPredicate,
        from context: NSManagedObjectContext
    ) -> Result<CoreReminder?, CrudErrors> {
        filter(by: predicate, limit: 1, from: context).map(\.first)
    }

    /// Filtered list of reminder depending on the given predicate query.
    /// - Parameters:
    ///   - predicate: Query to filter the reminders on.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing an array with filtered reminders on success or ``CrudErrors`` on failure.
    public static func filter(
        by predicate: NSPredicate,
        from context: NSManagedObjectContext
    ) -> Result<[CoreReminder], CrudErrors> {
        filter(by: predicate, limit: nil, from: context)
    }

    /// Filtered list of reminder depending on the given predicate query.
    /// - Parameters:
    ///   - predicate: Query to filter the reminders on.
    ///   - limit: The maximum amount of reminders to return.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing an array with filtered reminders on success or ``CrudErrors`` on failure.
    public static func filter(
        by predicate: NSPredicate,
        limit: Int?,
        from context: NSManagedObjectContext
    ) -> Result<[CoreReminder], CrudErrors> {
        let request = request(by: predicate, limit: limit)

        let result: [CoreReminder]
        do {
            result = try context.fetch(request)
        } catch {
            logger.error(label: "error while fetching reminders", error: error)
            return .failure(.fetchFailure(context: error))
        }

        return .success(result)
    }

    // - MARK: Internal properties/methods

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
            logger.error(label: "failed to clear reminders", error: error)
            return .failure(.clearFailure(context: error))
        }

        return save(from: context)
    }
    #endif

    // - MARK: Private properties/methods

    private func updateValues(with arguments: ReminderArguments) -> CoreReminder {
        time = arguments.time
        updateDate = Date()

        return self
    }

    private static func save(from context: NSManagedObjectContext) -> Result<Void, CrudErrors> {
        do {
            try context.save()
        } catch {
            logger.error(label: "error while creating a reminder", error: error)
            return .failure(.saveFailure(context: error))
        }

        return .success(())
    }

    private static func request(by predicate: NSPredicate? = nil, limit: Int? = nil) -> NSFetchRequest<CoreReminder> {
        let request = NSFetchRequest<CoreReminder>(entityName: String(describing: CoreReminder.self))
        if let predicate = predicate {
            request.predicate = predicate
        }
        if let limit = limit {
            request.fetchLimit = limit
        }
        return request
    }
}
