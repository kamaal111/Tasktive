//
//  Skypiea.swift
//
//
//  Created by Kamaal M Farah on 25/08/2022.
//

import CloudKit
import ICloutKit

/// Handle CloudKit operations
public struct Skypiea {
    private let preview: Bool
    private let iCloutKit = ICloutKit(
        containerID: "iCloud.com.\(Bundle.main.bundleIdentifier!)",
        databaseType: .private
    )

    private init(preview: Bool = false) {
        self.preview = preview
    }

    /// Fetch all of the given record.
    /// - Parameter objectType: `CloudKit` object
    /// - Returns: an array of records
    func list(ofType objectType: String) async throws -> [CKRecord] {
        guard !preview else {
            /// - TODO: SOME PREVIEW DATA
            return []
        }

        let predicate = NSPredicate(value: true)
        return try await filter(ofType: objectType, by: predicate)
    }

    /// Fetch with query.
    /// - Parameters:
    ///   - objectType: `CloudKit` object.
    ///   - predicate: query.
    /// - Returns: an array of records
    func filter(ofType objectType: String, by predicate: NSPredicate) async throws -> [CKRecord] {
        guard !preview else {
            /// - TODO: SOME PREVIEW DATA
            return []
        }

        return try await iCloutKit.fetch(ofType: objectType, by: predicate)
    }

    /// Save the given record on iCloud.
    /// - Parameter record: the record to save.
    /// - Returns: the saved record if it succeeds.
    func save(_ record: CKRecord) async throws -> CKRecord? {
        guard !preview else { return record }

        return try await iCloutKit.save(record)
    }

    /// Save many records in batch.
    /// - Parameter records: the records to save.
    /// - Returns: the updated records.
    func saveMany(_ records: [CKRecord]) async throws -> [CKRecord] {
        guard !preview else { return records }

        return try await iCloutKit.saveMultiple(records)
    }

    /// Deletes the given record.
    /// - Parameter record: the record to delete
    func delete(_ record: CKRecord) async throws {
        guard !preview else { return }

        _ = try await iCloutKit.delete(record)
    }

    /// Singleton class for easy access of ``Skypiea/Skypiea``
    public static let shared = Skypiea()

    /// Singleton class for debugging use-cases
    public static let preview = Skypiea(preview: true)
}
