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

    func create<T: Crudable>(with arguments: T.Arguments, from context: T.Context,
                             of type: T.Type) -> Result<T.ReturnType, T.CrudErrors> {
        type.create(with: arguments, from: context)
    }

    func updateManyTaskDates(by ids: [UUID], date: Date,
                             context: NSManagedObjectContext) -> Result<Void, CoreTask.CrudErrors> {
        CoreTask.updateManyDates(by: ids, date: date, on: context)
    }
}
