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
    static func create(with _: TaskArguments, from _: Skypiea) -> Result<CloudTask, CrudErrors> {
        .failure(.generalFailure(message: "oops"))
    }

    func update(with _: TaskArguments) -> Result<CloudTask, CrudErrors> {
        .failure(.generalFailure(message: "oops"))
    }

    func delete() -> Result<Void, CrudErrors> {
        .failure(.generalFailure(message: "oops"))
    }

    static func list(from _: Skypiea) -> Result<[CloudTask], CrudErrors> {
        .failure(.generalFailure(message: "oops"))
    }

    static func filter(by _: NSPredicate, limit _: Int?, from _: Skypiea) -> Result<[CloudTask], CrudErrors> {
        .failure(.generalFailure(message: "oops"))
    }

    static func filter(by _: NSPredicate, from _: Skypiea) -> Result<[CloudTask], CrudErrors> {
        .failure(.generalFailure(message: "oops"))
    }

    static func updateManyDates(by _: [UUID], date _: Date, on _: Skypiea) -> Result<Void, CrudErrors> {
        .failure(.generalFailure(message: "oops"))
    }

    enum CrudErrors: Error {
        case saveFailure
        case fetchFailure
        case updateManyFailure
        case generalFailure(message: String)
    }
}
