//
//  CloudTask+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 31/08/2022.
//

import Skypiea
import Foundation

extension CloudTask: Taskable {
    var source: DataSource {
        .iCloud
    }
}

extension CloudTask: Crudable {
    static func create(with arguments: TaskArguments, from context: Skypiea) async -> Result<CloudTask, CrudErrors> {
        let createdTask: CloudTask?
        do {
            createdTask = try await CloudTask.create(arguments.toCloudTask, on: context)
        } catch {
            return .failure(.saveFailure)
        }

        guard let createdTask = createdTask else { return .failure(.saveFailure) }

        return .success(createdTask)
    }

    func update(with arguments: TaskArguments, on context: Skypiea) async -> Result<CloudTask, CrudErrors> {
        let updatedTask: CloudTask?
        do {
            updatedTask = try await update(updateArguments(arguments), on: context)
        } catch {
            return .failure(.saveFailure)
        }

        guard let updatedTask = updatedTask else { return .failure(.updateFailure) }

        return .success(updatedTask)
    }

    func delete(on context: Skypiea) async -> Result<Void, CrudErrors> {
        do {
            try await delete(onContext: context)
        } catch {
            return .failure(.deleteFailure)
        }

        return .success(())
    }

    static func list(from context: Skypiea) async -> Result<[CloudTask], CrudErrors> {
        let tasks: [CloudTask]
        do {
            tasks = try await CloudTask.list(from: context)
        } catch {
            return .failure(.fetchFailure)
        }
        return .success(tasks)
    }

    static func filter(by predicate: NSPredicate,
                       limit _: Int?,
                       from context: Skypiea) async -> Result<[CloudTask], CrudErrors> {
        await filter(by: predicate, from: context)
    }

    static func filter(by predicate: NSPredicate, from context: Skypiea) async -> Result<[CloudTask], CrudErrors> {
        let tasks: [CloudTask]
        do {
            tasks = try await CloudTask.filter(by: predicate, from: context)
        } catch {
            return .failure(.fetchFailure)
        }
        return .success(tasks)
    }

    static func updateManyDates(by _: [UUID], date _: Date, on _: Skypiea) async -> Result<Void, CrudErrors> {
//        .failure(.generalFailure(message: "oops"))
        .success(())
    }

    enum CrudErrors: Error {
        case saveFailure
        case fetchFailure
        case updateManyFailure
        case updateFailure
        case deleteFailure
        case generalFailure(message: String)
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
            title: title
        )
    }
}
