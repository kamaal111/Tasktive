//
//  Crudable.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Foundation

/// Protocol to help with CRUD operations.
public protocol Crudable {
    /// The object type to return.
    associatedtype ReturnType: Crudable
    /// The errors to expect.
    associatedtype CrudErrors: Error
    /// The context object to help with the CRUD operations.
    associatedtype Context

    /// Update the object.
    /// - Parameters:
    ///   - arguments: The arguments to use to update the object.
    ///   - context: The context object to help with the CRUD operations.
    /// - Returns: A result either containing the return type on success or the protocol given error on failure.
    func update(with arguments: TaskArguments, on context: Context) async -> Result<ReturnType, CrudErrors>

    /// Delete the object.
    /// - Parameter context: The context object to help with the CRUD operations.
    /// - Returns: A result either containing nothing (`Void`) on success or the protocol given error on failure.
    func delete(on context: Context) async -> Result<Void, CrudErrors>

    /// Create a object.
    /// - Parameters:
    ///   - arguments: The arguments to use to create the object.
    ///   - context: The context object to help with the CRUD operations.
    /// - Returns: The created object on success or the protocol given error on failure.
    static func create(with arguments: TaskArguments, from context: Context) async -> Result<ReturnType, CrudErrors>

    /// List the objects.
    /// - Parameter context: The arguments to use to create the object.
    /// - Returns: Array of objects on success or the protocol given error on failure.
    static func list(from context: Context) async -> Result<[ReturnType], CrudErrors>

    /// Filtered list of objects.
    /// - Parameters:
    ///   - predicate: The predicate query.
    ///   - limit: How many objects to return on a maximum.
    ///   - context: The context object to help with the CRUD operations.
    /// - Returns: Filtered array of objects on success or the protocol given error on failure.
    static func filter(
        by predicate: NSPredicate,
        limit: Int?,
        from context: Context
    ) async -> Result<[ReturnType], CrudErrors>

    /// Filtered list of objects.
    /// - Parameters:
    ///   - predicate: The predicate query.
    ///   - context: The context object to help with the CRUD operations.
    /// - Returns: Filtered array of objects on success or the protocol given error on failure.
    static func filter(by predicate: NSPredicate, from context: Context) async -> Result<[ReturnType], CrudErrors>

    /// A single object searched by a predicate.
    /// - Parameters:
    ///   - predicate: The predicate query.
    ///   - context: The context object to help with the CRUD operations.
    /// - Returns: A single optional object on success or the protocol given error on failure.
    static func find(by predicate: NSPredicate, from context: Context) async -> Result<ReturnType?, CrudErrors>
}
