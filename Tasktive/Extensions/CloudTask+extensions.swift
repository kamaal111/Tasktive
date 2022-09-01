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
        let now = Date()
        let object = CloudTask(
            id: arguments.id ?? UUID(),
            creationDate: now,
            updateDate: now,
            completionDate: arguments.completionDate,
            dueDate: arguments.dueDate,
            notes: arguments.notes,
            taskDescription: arguments.taskDescription,
            ticked: arguments.ticked,
            title: arguments.title
        )

        let createdTask: CloudTask?
        do {
            createdTask = try await CloudTask.create(object, on: context)
        } catch {
            return .failure(.saveFailure)
        }

        guard let createdTask = createdTask else { return .failure(.saveFailure) }

        return .success(createdTask)
    }

    func update(with _: TaskArguments) async -> Result<CloudTask, CrudErrors> {
        .failure(.generalFailure(message: "oops"))
    }

    func delete() async -> Result<Void, CrudErrors> {
        .failure(.generalFailure(message: "oops"))
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
        case generalFailure(message: String)
    }
}
