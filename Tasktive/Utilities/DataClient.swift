//
//  DataClient.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import Foundation

struct DataClient {
    init() { }

    func listTasks<T: Crudable>(from context: T.Context, of type: T.Type) -> Result<[T.ReturnType], T.CrudErrors> {
        type.list(from: context)
    }
}
