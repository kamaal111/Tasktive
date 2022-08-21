//
//  DataClient.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import CoreData
import Foundation

struct DataClient {
    init() { }

    func list<T: Crudable>(from context: T.Context, of type: T.Type) -> Result<[T.ReturnType], T.CrudErrors> {
        type.list(from: context)
    }

    func filter<T: Crudable>(by predicate: NSPredicate,
                             limit: Int? = nil,
                             from context: T.Context,
                             of type: T.Type) -> Result<[T.ReturnType], T.CrudErrors> {
        type.filter(by: predicate, limit: limit, from: context)
    }

    func create<T: Crudable>(with arguments: T.Arguments,
                             from context: T.Context,
                             of type: T.Type) -> Result<T.ReturnType, T.CrudErrors> {
        type.create(with: arguments, from: context)
    }

    func update<T: Crudable>(by id: UUID,
                             with arguments: T.ReturnType.Arguments,
                             from context: T.Context,
                             of type: T.Type) -> Result<T.ReturnType.ReturnType, UpdateErrors> {
        let predicate = NSPredicate(format: "id == %@", id.nsString)
        let result = filter(by: predicate, from: context, of: type)
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
            .mapError { UpdateErrors.crud(error: $0) }
    }

    enum UpdateErrors: Error {
        case crud(error: Error)
        case notFound
    }
}
