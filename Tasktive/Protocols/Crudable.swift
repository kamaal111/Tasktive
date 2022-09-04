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

    var asAppTask: AppTask { get }

    func update(with arguments: TaskArguments, on context: Context) async -> Result<ReturnType, CrudErrors>
    func delete(on context: Context) async -> Result<Void, CrudErrors>

    static func create(with arguments: TaskArguments, from context: Context) async -> Result<ReturnType, CrudErrors>
    static func list(from context: Context) async -> Result<[ReturnType], CrudErrors>
    static func filter(
        by predicate: NSPredicate,
        limit: Int?,
        from context: Context
    ) async -> Result<[ReturnType], CrudErrors>
    static func filter(by predicate: NSPredicate, from context: Context) async -> Result<[ReturnType], CrudErrors>
    static func find(by predicate: NSPredicate, from context: Context) async -> Result<ReturnType?, CrudErrors>
}
