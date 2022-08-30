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
        guard let savedRecord = try await context.save(object.record) else { return nil }

        return fromRecord(savedRecord)
    }

    /// Fetch all of the given record.
    /// - Parameter context: the context to use for iCloud operations.
    /// - Returns: An array of the fetched objects.
    public static func fetchAll(from context: Skypiea) async throws -> [Object] {
        try await context.fetchAll(ofType: recordType)
            .compactMap(fromRecord(_:))
    }
}
