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

public class TasksClient {
    private let persistenceController: PersistenceController
    private let skypiea: Skypiea

    public init(preview: Bool) {
        if !preview {
            self.persistenceController = .shared
            self.skypiea = .shared
        } else {
            self.persistenceController = .preview
            self.skypiea = .preview
        }
    }

    public func list(from source: DataSource) async throws -> [AppTask] {
        switch source {
        case .coreData:
            return try CoreTask.list(from: persistenceController.context)
                .get()
                .map(\.asAppTask)
        case .iCloud:
            return try await CloudTask.list(from: skypiea)
                .get()
                .map(\.asAppTask)
        }
    }

    public func filter(from source: DataSource, by queryString: String?, limit: Int? = nil) async throws -> [AppTask] {
        guard let queryString = queryString else { return try await list(from: source) }

        let predicate = NSPredicate(format: queryString)

        switch source {
        case .coreData:
            return try CoreTask.filter(by: predicate, limit: limit, from: persistenceController.context)
                .get()
                .map(\.asAppTask)
        case .iCloud:
            return try await CloudTask.filter(by: predicate, limit: limit, from: skypiea)
                .get()
                .map(\.asAppTask)
        }
    }

    public func create(on source: DataSource, with arguments: TaskArguments) async throws -> AppTask {
        let object: any Taskable
        switch source {
        case .coreData:
            object = try CoreTask.create(with: arguments, from: persistenceController.context).get()
        case .iCloud:
            object = try await CloudTask.create(with: arguments, from: skypiea).get()
        }

        return object.asAppTask
    }

    public func update(on source: DataSource, by id: UUID, with arguments: TaskArguments) async throws -> AppTask {
        let predicate = NSPredicate(format: "id == %@", id.nsString)

        let object: (any Taskable)?
        switch source {
        case .coreData:
            object = try await CoreTask.find(by: predicate, from: persistenceController.context)
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

    public func delete(on source: DataSource, by id: UUID) async throws {
        let predicate = NSPredicate(format: "id == %@", id.nsString)

        switch source {
        case .coreData:
            try await CoreTask.find(by: predicate, from: persistenceController.context)
                .get()?
                .delete(on: persistenceController.context)
                .get()
        case .iCloud:
            try await CloudTask.find(by: predicate, from: skypiea)
                .get()?
                .delete(on: skypiea)
                .get()
        }
    }

    public func updateManyDates(_ tasks: [AppTask], from source: DataSource, date: Date) async throws {
        switch source {
        case .coreData:
            _ = try CoreTask.updateManyDates(tasks, date: date, on: persistenceController.context).get()
        case .iCloud:
            _ = try await CloudTask.updateManyDates(tasks, date: date, on: skypiea).get()
        }
    }

    public enum Errors: Error {
        case notFound
    }
}
