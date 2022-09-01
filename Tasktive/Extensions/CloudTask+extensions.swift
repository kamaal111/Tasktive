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
    static func create(with _: TaskArguments, from _: Skypiea) async -> Result<CloudTask, CrudErrors> {
        .failure(.generalFailure(message: "oops"))
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
