//
//  TasksClient.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import CoreData
import Foundation

struct TasksClient {
    init() { }

    func list<T: Crudable>(from context: T.Context, of type: T.Type) -> Result<[AppTask], T.CrudErrors> {
        type.list(from: context)
            .map {
                $0.map(\.asAppTask)
            }
    }

    func filter<T: Crudable>(by predicate: NSPredicate,
                             limit: Int? = nil,
                             from context: T.Context,
                             of type: T.Type) -> Result<[AppTask], T.CrudErrors> {
        type.filter(by: predicate, limit: limit, from: context)
            .map {
                $0.map(\.asAppTask)
            }
    }

    func find<T: Crudable>(by predicate: NSPredicate,
                           from context: T.Context,
                           of type: T.Type) -> Result<AppTask?, T.CrudErrors> {
        filter(by: predicate, limit: 1, from: context, of: type)
            .map(\.first)
    }

    func create<T: Crudable>(with arguments: TaskArguments,
                             from context: T.Context,
                             of type: T.Type) -> Result<AppTask, T.CrudErrors> {
        type.create(with: arguments, from: context)
            .map(\.asAppTask)
    }

    func update<T: Crudable>(by id: UUID,
                             with arguments: TaskArguments,
                             from context: T.Context,
                             of type: T.Type) -> Result<AppTask, UpdateErrors> {
        let predicate = NSPredicate(format: "id == %@", id.nsString)
        let result = type.filter(by: predicate, from: context)
            .map(\.first)
            .mapError { UpdateErrors.crud(error: $0) }
        let item: T.ReturnType?
        switch result {
        case let .failure(failure):
            return .failure(failure)
        case let .success(success):
            item = success
        }

        guard let item = item else { return .failure(.notFound) }

        return item.update(with: arguments)
            .map(\.asAppTask)
            .mapError { UpdateErrors.crud(error: $0) }
    }

    enum UpdateErrors: Error {
        case crud(error: Error)
        case notFound
    }
}
