//
//  CloudTask+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 31/08/2022.
//

import Skypiea
import Logster
import CloudKit
import Foundation
import SharedModels

private let logger = Logster(from: CloudTask.self)

extension CloudTask: Taskable {
    public var source: DataSource {
        .iCloud
    }
}

extension CloudTask: Crudable {
    public static func create(
        with arguments: TaskArguments,
        from context: Skypiea
    ) async -> Result<CloudTask, CrudErrors> {
        let createdTask: CloudTask?
        do {
            createdTask = try await CloudTask.create(arguments.toCloudTask, on: context)
        } catch {
            logger.error(label: "failed to create cloud task", error: error)
            return .failure(.saveFailure(context: error))
        }

        guard let createdTask = createdTask else { return .failure(.saveFailure()) }

        return .success(createdTask)
    }

    public func update(with arguments: TaskArguments, on context: Skypiea) async -> Result<CloudTask, CrudErrors> {
        let updatedTask: CloudTask?
        do {
            updatedTask = try await update(updateArguments(arguments), on: context)
        } catch {
            return .failure(.saveFailure(context: error))
        }

        guard let updatedTask = updatedTask else { return .failure(.updateFailure()) }

        return .success(updatedTask)
    }

    public func delete(on context: Skypiea) async -> Result<Void, CrudErrors> {
        do {
            try await delete(onContext: context)
        } catch {
            return .failure(.deleteFailure(context: error))
        }

        return .success(())
    }

    public static func list(from context: Skypiea) async -> Result<[CloudTask], CrudErrors> {
        let tasks: [CloudTask]
        do {
            tasks = try await CloudTask.list(from: context)
        } catch {
            return handleFetchErrors(error)
        }
        return .success(tasks)
    }

    public static func filter(
        by predicate: NSPredicate,
        limit: Int?,
        from context: Skypiea
    ) async -> Result<[CloudTask], CrudErrors> {
        let tasks: [CloudTask]
        do {
            tasks = try await CloudTask.filter(by: predicate, limit: limit, from: context)
        } catch {
            return handleFetchErrors(error)
        }
        return .success(tasks)
    }

    public static func filter(
        by predicate: NSPredicate,
        from context: Skypiea
    ) async -> Result<[CloudTask], CrudErrors> {
        await filter(by: predicate, limit: nil, from: context)
    }

    public static func find(by predicate: NSPredicate, from context: Skypiea) async -> Result<CloudTask?, CrudErrors> {
        let task: CloudTask?
        do {
            task = try await CloudTask.find(by: predicate, from: context)
        } catch {
            return handleFetchErrors(error).map(\.first)
        }

        return .success(task)
    }

    static func updateManyDates(_ tasks: [AppTask], date: Date, on context: Skypiea) async -> Result<Void, CrudErrors> {
        guard !tasks.isEmpty else { return .success(()) }

        do {
            _ = try await CloudTask.updateMany(tasks.map { $0.cloudTaskWithUpdatedDueDate(date) }, on: context)
        } catch {
            logger.error(label: "error while deleting tasks", error: error)
            return .failure(.updateManyFailure(context: error))
        }

        return .success(())
    }

    private static func handleFetchErrors(_ error: Error) -> Result<[CloudTask], CrudErrors> {
        if let error = error as? CKError {
            switch error.code {
            case .unknownItem:
                logger.info("record not created yet")
                return .success([])
            default:
                break
            }
        }

        return .failure(.fetchFailure(context: error))
    }

    public enum CrudErrors: Error {
        case saveFailure(context: Error? = nil)
        case fetchFailure(context: Error? = nil)
        case updateManyFailure(context: Error? = nil)
        case updateFailure(context: Error? = nil)
        case deleteFailure(context: Error? = nil)
        case generalFailure(message: String)
    }
}

extension AppTask {
    fileprivate func cloudTaskWithUpdatedDueDate(_ date: Date) -> CloudTask {
        CloudTask(
            id: id,
            creationDate: creationDate,
            updateDate: Date(),
            completionDate: completionDate,
            dueDate: date,
            notes: notes,
            taskDescription: taskDescription,
            ticked: ticked,
            title: title,
            record: record
        )
    }
}

extension CloudTask {
    private func updateArguments(_ arguments: TaskArguments) -> CloudTask {
        CloudTask(
            id: id,
            creationDate: creationDate,
            updateDate: Date(),
            completionDate: arguments.completionDate,
            dueDate: arguments.dueDate,
            notes: arguments.notes,
            taskDescription: arguments.taskDescription,
            ticked: arguments.ticked,
            title: arguments.title,
            record: record
        )
    }
}

extension TaskArguments {
    fileprivate var toCloudTask: CloudTask {
        let now = Date()

        return CloudTask(
            id: id ?? UUID(),
            creationDate: now,
            updateDate: now,
            completionDate: completionDate,
            dueDate: dueDate,
            notes: notes,
            taskDescription: taskDescription,
            ticked: ticked,
            title: title,
            record: nil
        )
    }
}
