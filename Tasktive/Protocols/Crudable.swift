//
//  Crudable.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import Foundation

protocol Crudable {
    associatedtype ReturnType: Crudable
    associatedtype CrudErrors: Error
    associatedtype Context
    associatedtype Arguments

    static func create(with args: Arguments, from context: Context) -> Result<ReturnType, CrudErrors>
    static func list(from context: Context) -> Result<[ReturnType], CrudErrors>
}
