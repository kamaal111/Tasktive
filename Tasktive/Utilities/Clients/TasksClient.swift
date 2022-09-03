//
//  TasksClient.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import Skypiea
import Foundation

class TasksClient {
    private let persistenceController: PersistenceController
    private let skypiea: Skypiea

    init(persistenceController: PersistenceController, skypiea: Skypiea) {
        self.persistenceController = persistenceController
        self.skypiea = skypiea
    }

    func list(from source: DataSource) async throws -> [AppTask] {
        let objects: [any Crudable]
        switch source {
        case .coreData:
            objects = try CoreTask.list(from: persistenceController.context).get()
        case .iCloud:
            objects = try await CloudTask.list(from: skypiea).get()
        }

        return objects.map(\.asAppTask)
    }

    func filter(from source: DataSource, by queryString: String?, limit: Int? = nil) async throws -> [AppTask] {
        guard let queryString = queryString else { return try await list(from: source) }

        let predicate = NSPredicate(format: queryString)

        let objects: [any Crudable]
        switch source {
        case .coreData:
            objects = try CoreTask.filter(by: predicate, limit: limit, from: persistenceController.context).get()
        case .iCloud:
            objects = try await CloudTask.filter(by: predicate, limit: limit, from: skypiea).get()
        }

        return objects.map(\.asAppTask)
    }

    func create(on source: DataSource, with arguments: TaskArguments) async throws -> AppTask {
        let object: any Crudable
        switch source {
        case .coreData:
            object = try CoreTask.create(with: arguments, from: persistenceController.context).get()
        case .iCloud:
            object = try await CloudTask.create(with: arguments, from: skypiea).get()
        }

        return object.asAppTask
    }

    func update(on source: DataSource, by id: UUID, with arguments: TaskArguments) async throws -> AppTask {
        let predicate = NSPredicate(format: "id == %@", id.nsString)

        let object: (any Crudable)?
        switch source {
        case .coreData:
            object = try CoreTask.find(by: predicate, from: persistenceController.context)
                .get()?
                .update(with: arguments, on: persistenceController.context)
                .get()
        case .iCloud:
            object = try await CloudTask.find(by: predicate, from: skypiea)
                .get()?
                .update(with: arguments, on: skypiea)
                .get()
        }

        guard let object = object else { throw Errors.notFound }

        return object.asAppTask
    }

    func updateManyDates(_ tasks: [AppTask], from source: DataSource, date: Date) async throws {
        switch source {
        case .coreData:
            _ = try CoreTask.updateManyDates(tasks, date: date, on: persistenceController.context).get()
        case .iCloud:
            _ = try await CloudTask.updateManyDates(tasks, date: date, on: skypiea).get()
        }
    }

    enum Errors: Error {
        case notFound
    }
}
