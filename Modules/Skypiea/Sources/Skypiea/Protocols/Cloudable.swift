//
//  Cloudable.swift
//
//
//  Created by Kamaal M Farah on 27/08/2022.
//

import CloudKit
import ICloutKit
import Foundation
import ShrimpExtensions

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

/// Error overrides of ``Cloudable``
public enum CloudableErrors: Error {
    /// iCloud has been disabled by the user.
    case iCloudDisabledByUser
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
        let items: [CKRecord]

        do {
            items = try await context.list(ofType: recordType)
        } catch {
            try handleFetchErrors(error)
            throw error
        }

        return items
            .compactMap(fromRecord(_:))
    }

    /// Fetch with query of the given record.
    /// - Parameters:
    ///   - context: the context to use for iCloud operations.
    ///   - limit: the amount to limit by.
    ///   - predicate: query.
    /// - Returns: an array of the fetched objects.
    public static func filter(by predicate: NSPredicate,
                              limit: Int? = nil,
                              from context: Skypiea) async throws -> [Object] {
        let items: [CKRecord]

        do {
            items = try await context.filter(ofType: recordType, by: predicate)
        } catch {
            try handleFetchErrors(error)
            throw error
        }

        if let limit = limit {
            return items
                .compactMap(fromRecord(_:))
                .prefix(upTo: limit)
                .asArray()
        }

        return items
            .compactMap(fromRecord(_:))
    }

    /// Finds a record by the given record.
    /// - Parameters:
    ///   - predicate: query.
    ///   - context: the context to use for iCloud operations.
    /// - Returns: the searched for object.
    public static func find(by predicate: NSPredicate, from context: Skypiea) async throws -> Object? {
        try await filter(by: predicate, limit: 1, from: context)
            .first
    }

    /// Update a currently existing record.
    /// - Parameters:
    ///   - object: the object to update.
    ///   - context: the context to use for iCloud operations.
    /// - Returns: the updated object when it succeeds.
    public func update(_ object: Object, on context: Skypiea) async throws -> Object? {
        try await Self.save(object, on: context)
    }

    /// Delete the current record.
    /// - Parameter context: the context to use for iCloud operations.
    public func delete(onContext context: Skypiea) async throws {
        try await context.delete(record)
    }

    /// Update many records in batch.
    /// - Parameters:
    ///   - objects: the objects to update.
    ///   - context: the context to use for iCloud operations.
    /// - Returns: the updated objects.
    public static func updateMany(_ objects: [Object], on context: Skypiea) async throws -> [Object] {
        try await context.saveMany(objects.map(\.record))
            .compactMap(fromRecord(_:))
    }

    private static func handleFetchErrors(_ error: Error) throws {
        if let accountErrors = error as? ICloutKit.AccountErrors {
            switch accountErrors {
            case .accountStatusNoAccount:
                throw CloudableErrors.iCloudDisabledByUser
            default:
                break
            }
        }
    }

    private static func save(_ object: Object, on context: Skypiea) async throws -> Object? {
        let record = object.record
        guard let savedRecord = try await context.save(record) else { return nil }

        return Self.fromRecord(savedRecord)
    }
}
