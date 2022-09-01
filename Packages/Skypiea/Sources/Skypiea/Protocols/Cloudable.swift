//
//  Cloudable.swift
//
//
//  Created by Kamaal M Farah on 27/08/2022.
//

import CloudKit
import Foundation

/// Protocol to help perform iCloud operations.
public protocol Cloudable {
    /// The object type to perform iCloud operations on.
    associatedtype Object: Cloudable

    /// New or existing `CKRecord`
    var record: CKRecord { get }

    /// Static initializer to create an ``Cloudable`` object out of a `CKRecord`.
    /// - Parameter record: the record to create the ``Cloudable`` object out of.
    /// - Returns: an ``Cloudable`` object.
    static func fromRecord(_ record: CKRecord) -> Object?

    /// The `CKRecord` recordType string.
    static var recordType: String { get }
}

extension Cloudable {
    /// Create new entry on iCloud.
    /// - Parameters:
    ///   - object: the object to save.
    ///   - context: the context to use for iCloud operations.
    /// - Returns: the saved object when it succeeds.
    public static func create(_ object: Object, on context: Skypiea) async throws -> Object? {
        try await save(object, on: context)
    }

    /// Fetch all of the given record.
    /// - Parameter context: the context to use for iCloud operations.
    /// - Returns: an array of the fetched objects.
    public static func list(from context: Skypiea) async throws -> [Object] {
        try await context.list(ofType: recordType)
            .compactMap(fromRecord(_:))
    }

    /// Fetch with query of the given record.
    /// - Parameters:
    ///   - context: the context to use for iCloud operations.
    ///   - predicate: query.
    /// - Returns: an array of the fetched objects.
    public static func filter(by predicate: NSPredicate, from context: Skypiea) async throws -> [Object] {
        try await context.filter(ofType: recordType, by: predicate)
            .compactMap(fromRecord(_:))
    }

    /// Update a currently existing record.
    /// - Parameters:
    ///   - object: the object to update.
    ///   - context: the context to use for iCloud operations.
    /// - Returns: the updated object when it succeeds.
    public func update(_ object: Object, on context: Skypiea) async throws -> Object? {
        try await Self.save(object, on: context)
    }

    private static func save(_ object: Object, on context: Skypiea) async throws -> Object? {
        guard let savedRecord = try await context.save(object.record) else { return nil }

        return Self.fromRecord(savedRecord)
    }
}
