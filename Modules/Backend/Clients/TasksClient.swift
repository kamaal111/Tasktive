//
//  TasksClient.swift
//  Backend
//
//  Created by Kamaal M Farah on 28/09/2022.
//

import Skypiea
import CDPersist
import Foundation
import SharedModels
import ShrimpExtensions

/// Client to handle all tasks store modifications.
public class TasksClient {
    private let persistenceController: PersistenceController
    private let skypiea: Skypiea

    /// Initializer of ``TasksClient``
    /// - Parameter preview: Whether to return static preview data or not.
    public init(preview: Bool) {
        if !preview {
            self.persistenceController = .shared
            self.skypiea = .shared
        } else {
            self.persistenceController = .preview
            self.skypiea = .preview
        }
    }

    /// List all tasks from the given `DataSource`.
    /// - Parameter source: Where to get the tasks from.
    /// - Returns: A result either containing an array with all tasks on success or ``Errors`` on failure.
    public func list(from source: DataSource) async -> Result<[AppTask], Errors> {
        switch source {
        case .coreData:
            return CoreTask.list(from: persistenceController.context)
                .mapError(mapCoreTaskErrors)
                .map { $0.map(\.asAppTask) }
        case .iCloud:
            return await CloudTask.list(from: skypiea)
                .mapError(mapCloudTaskErrors)
                .map { $0.map(\.asAppTask) }
        }
    }

    /// Filters tasks using the given query from the given `DataSource`.
    /// - Parameters:
    ///   - source: Where to get the tasks from.
    ///   - queryString: The query to filters tasks with.
    ///   - limit: The maximum amount of tasks to return, if this value is kepts nil then there is no limit.
    /// - Returns: A result either containing an array with filtered tasks on success or ``Errors`` on failure.
    public func filter(
        from source: DataSource,
        by queryString: String,
        limit: Int? = nil
    ) async -> Result<[AppTask], Errors> {
        let predicate = NSPredicate(format: queryString)

        switch source {
        case .coreData:
            return CoreTask.filter(by: predicate, limit: limit, from: persistenceController.context)
                .mapError(mapCoreTaskErrors)
                .map { $0.map(\.asAppTask) }
        case .iCloud:
            return await CloudTask.filter(by: predicate, limit: limit, from: skypiea)
                .mapError(mapCloudTaskErrors)
                .map { $0.map(\.asAppTask) }
        }
    }

    /// Creates a task using the given arguments on the given `DataSource`.
    /// - Parameters:
    ///   - source: Where to create the tasks on.
    ///   - arguments: The arguments used to create a task.
    /// - Returns: A result either containing the created task on success or ``Errors`` on failure.
    public func create(on source: DataSource, with arguments: TaskArguments) async -> Result<AppTask, Errors> {
        switch source {
        case .coreData:
            return CoreTask.create(with: arguments, from: persistenceController.context)
                .mapError(mapCoreTaskErrors)
                .map(\.asAppTask)
        case .iCloud:
            return await CloudTask.create(with: arguments, from: skypiea)
                .mapError(mapCloudTaskErrors)
                .map(\.asAppTask)
        }
    }

    /// Update the task by id.
    /// - Parameters:
    ///   - source: Where to create the tasks on.
    ///   - id: The search id.
    ///   - arguments: The arguments used to update the task.
    /// - Returns:  A result either containing the updated task on success or ``Errors`` on failure.
    public func update(
        on source: DataSource,
        by id: UUID,
        with arguments: TaskArguments
    ) async -> Result<AppTask, Errors> {
        switch source {
        case .coreData:
            let foundTask: CoreTask
            let findResult = findCoreTask(by: id)
            switch findResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                foundTask = success
            }

            return await foundTask.update(with: arguments, on: persistenceController.context)
                .mapError(mapCoreTaskErrors)
                .map(\.asAppTask)
        case .iCloud:
            let foundTask: CloudTask
            let findResult = await findCloudTask(by: id)
            switch findResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                foundTask = success
            }

            return await foundTask.update(with: arguments, on: skypiea)
                .mapError(mapCloudTaskErrors)
                .map(\.asAppTask)
        }
    }

    /// Delete the task by id.
    /// - Parameters:
    ///   - source: Where to create the tasks on.
    ///   - id: The search id.
    /// - Returns: A result either containing nothing (`Void`) on success or ``Errors`` on failure.
    public func delete(on source: DataSource, by id: UUID) async -> Result<Void, Errors> {
        switch source {
        case .coreData:
            let foundTask: CoreTask
            let findResult = findCoreTask(by: id)
            switch findResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                foundTask = success
            }

            return await foundTask.delete(on: persistenceController.context)
                .mapError(mapCoreTaskErrors)
        case .iCloud:
            let foundTask: CloudTask
            let findResult = await findCloudTask(by: id)
            switch findResult {
            case let .failure(failure):
                return .failure(failure)
            case let .success(success):
                foundTask = success
            }

            return await foundTask.delete(on: skypiea)
                .mapError(mapCloudTaskErrors)
        }
    }

    /// Update many due dates on tasks by date.
    /// - Parameters:
    ///   - tasks: The tasks to update.
    ///   - source: Where to create the tasks on.
    ///   - date: The new due date.
    /// - Returns: A result either containing nothing (`Void`) on success or ``Errors`` on failure.
    public func updateManyDates(_ tasks: [AppTask], from source: DataSource, date: Date) async -> Result<Void, Errors> {
        switch source {
        case .coreData:
            return CoreTask.updateManyDates(tasks, date: date, on: persistenceController.context)
                .mapError(mapCoreTaskErrors)
        case .iCloud:
            return await CloudTask.updateManyDates(tasks, date: date, on: skypiea)
                .mapError(mapCloudTaskErrors)
        }
    }

    /// Task failures.
    public enum Errors: Error {
        /// Failure while saving.
        case saveFailure(context: Error?)
        /// Failure while fetching.
        case fetchFailure(context: Error?)
        /// Failure while updating.
        case updateFailure(context: Error?)
        /// Failure while deleting.
        case deleteFailure(context: Error?)
        /// Failure while updating many tasks.
        case updateManyFailure(context: Error?)
        /// Failure while clearing tasks.
        case clearFailure(context: Error?)
        /// Task is not found.
        case notFound
        /// Unknown error.
        case generalFailure(message: String)
        /// iCloud is disabled by user.
        case iCloudDisabledByUser
    }

    private func findCoreTask(by id: UUID) -> Result<CoreTask, Errors> {
        let predicate = NSPredicate(format: "id == %@", id.nsString)

        let foundTask: CoreTask
        let findResult = CoreTask.find(by: predicate, from: persistenceController.context)
            .mapError(mapCoreTaskErrors)
        switch findResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            guard let success else { return .failure(.notFound) }
            foundTask = success
        }

        return .success(foundTask)
    }

    private func findCloudTask(by id: UUID) async -> Result<CloudTask, Errors> {
        let predicate = NSPredicate(format: "id == %@", id.nsString)

        let foundTask: CloudTask
        let findResult = await CloudTask.find(by: predicate, from: skypiea)
            .mapError(mapCloudTaskErrors)
        switch findResult {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            guard let success else { return .failure(.notFound) }
            foundTask = success
        }

        return .success(foundTask)
    }

    private func mapCoreTaskErrors(_ error: CoreTask.CrudErrors) -> Errors {
        switch error {
        case let .saveFailure(context):
            return .saveFailure(context: context)
        case let .fetchFailure(context):
            return .fetchFailure(context: context)
        case let .clearFailure(context):
            return .clearFailure(context: context)
        case let .deletionFailure(context):
            return .deleteFailure(context: context)
        case let .updateManyFailure(context):
            return .updateManyFailure(context: context)
        case let .generalFailure(message):
            return .generalFailure(message: message)
        }
    }

    private func mapCloudTaskErrors(_ error: CloudTask.CrudErrors) -> Errors {
        switch error {
        case let .saveFailure(context):
            return mapCloudTaskContextError(context) ?? .saveFailure(context: context)
        case let .fetchFailure(context):
            return mapCloudTaskContextError(context) ?? .fetchFailure(context: context)
        case let .updateManyFailure(context):
            return mapCloudTaskContextError(context) ?? .updateManyFailure(context: context)
        case let .updateFailure(context):
            return mapCloudTaskContextError(context) ?? .updateFailure(context: context)
        case let .deleteFailure(context):
            return mapCloudTaskContextError(context) ?? .deleteFailure(context: context)
        case let .generalFailure(message):
            return .generalFailure(message: message)
        }
    }

    private func mapCloudTaskContextError(_ error: Error?) -> Errors? {
        guard let error, let cloudErrors = error as? CloudableErrors else { return .none }

        switch cloudErrors {
        case .iCloudDisabledByUser:
            return .iCloudDisabledByUser
        }
    }
}
