//
//  CoreTask+extensions.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Logster
import CoreData
import Foundation

private let logger = Logster(from: CoreTask.self)

extension CoreTask {
    /// Errors that can come from `CoreData` operations.
    public enum CoreErrors: Error {
        /// Failure on saving a task.
        case saveFailure(context: Error?)
        /// General failure.
        case generalFailure(message: String)
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

    // - MARK: CoreData operations

    /// This static method creates a ``CoreTask`` instances and persists in the `CoreData` store.
    /// - Parameters:
    ///   - arguments: ``Arguments`` used to create the ``CoreTask`` instance.
    ///   - context: The context to use to operate the `CoreData` operation.
    /// - Returns: A result either containing ``CoreTask`` on success or ``CoreErrors`` on failure.
    public static func create(
        with arguments: Arguments,
        from context: NSManagedObjectContext
    ) -> Result<CoreTask, CoreErrors> {
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

    // - MARK: Arguments

    /// ``CoreTask`` arguments to create and/or update an instance.
    public struct Arguments: Equatable {
        /// Title to set on a ``CoreTask``.
        public var title: String
        /// Description to set on a ``CoreTask``.
        public let taskDescription: String?
        /// Notes to set on a ``CoreTask``.
        public let notes: String?
        /// Due date to set on a ``CoreTask``.
        public var dueDate: Date
        /// Ticked state to set on a ``CoreTask``.
        public let ticked: Bool
        /// Completion date to set on a ``CoreTask``.
        public let completionDate: Date?
        /// ID to set on a ``CoreTask``.
        public let id: UUID?

        /// Initializer of ``CoreTask/Arguments``.
        /// - Parameters:
        ///   - title: Title to set on a ``CoreTask``.
        ///   - taskDescription: Description to set on a ``CoreTask``.
        ///   - notes: Notes to set on a ``CoreTask``.
        ///   - dueDate: Due date to set on a ``CoreTask``.
        ///   - ticked: Ticked state to set on a ``CoreTask``.
        public init(title: String, taskDescription: String?, notes: String?, dueDate: Date, ticked: Bool) {
            self.title = title
            self.taskDescription = taskDescription
            self.notes = notes
            self.dueDate = dueDate
            self.ticked = ticked
            self.id = nil
            self.completionDate = nil
        }

        /// Initializer of ``CoreTask/Arguments``.
        /// - Parameters:
        ///   - title: Title to set on a ``CoreTask``.
        ///   - taskDescription: Description to set on a ``CoreTask``.
        ///   - notes: Notes to set on a ``CoreTask``.
        ///   - dueDate: Due date to set on a ``CoreTask``.
        public init(title: String, taskDescription: String?, notes: String?, dueDate: Date) {
            self.init(title: title, taskDescription: taskDescription, notes: notes, dueDate: dueDate, ticked: false)
        }

        /// Initializer of ``CoreTask/Arguments``.
        /// - Parameters:
        ///   - title: Title to set on a ``CoreTask``.
        ///   - taskDescription: Description to set on a ``CoreTask``.
        ///   - notes: Notes to set on a ``CoreTask``.
        ///   - dueDate: Due date to set on a ``CoreTask``.
        ///   - ticked: Ticked state to set on a ``CoreTask``.
        ///   - id: ID to set on a ``CoreTask``.
        ///   - completionDate: Completion date to set on a ``CoreTask``.
        public init(
            title: String,
            taskDescription: String?,
            notes: String?,
            dueDate: Date,
            ticked: Bool,
            id: UUID?,
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

    // - MARK: Private properties/methods

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

    private static func save(from context: NSManagedObjectContext) -> Result<Void, CoreErrors> {
        do {
            try context.save()
        } catch {
            logger.error(label: "error while creating a task", error: error)
            return .failure(.saveFailure(context: error))
        }

        return .success(())
    }
}
