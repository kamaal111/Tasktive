//
//  Skypiea.swift
//
//
//  Created by Kamaal M Farah on 25/08/2022.
//

import Logster
import CloudKit
import ICloutKit
import ShrimpExtensions

private let logger = Logster(from: Skypiea.self)

/// Handle CloudKit operations
public class Skypiea {
    /// Singleton class for easy access of ``Skypiea/Skypiea``
    public static let shared = Skypiea()

    /// Singleton class for debugging use-cases
    public static let preview = Skypiea(preview: true)

    private let preview: Bool
    private let iCloutKit = ICloutKit(
        containerID: "iCloud.com.io.kamaal.Tasktivity",
        databaseType: .private
    )
    private let subscriptionsWanted = [CloudTask.recordType]
    private(set) var subscriptions: [CKSubscription] = [] {
        didSet { logger.info("subscribed iCloud subscriptions; \(subscriptions)") }
    }

    private init(preview: Bool = false) {
        self.preview = preview
    }

    /// Subscribe to all iCloud subscriptions to recieve notifications.
    public func subscripeToAll() async throws {
        guard !preview else { return }

        let subscriptions = try await fetchAllSubcriptions()

        var subscribedSubsctiptions: [CKSubscription] = []
        for subscription in subscriptions {
            if let query = subscription as? CKQuerySubscription,
               let recordType = query.recordType,
               subscriptionsWanted.contains(recordType) {
                let subscribedSubscription: CKSubscription
                do {
                    subscribedSubscription = try await subscribeAll(toType: recordType)
                } catch {
                    logger.error(label: "failed to subscribe to \(recordType) iCloud subscription", error: error)
                    continue
                }

                subscribedSubsctiptions.append(subscribedSubscription)
            }
        }

        self.subscriptions = subscribedSubsctiptions
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

    private func fetchAllSubcriptions() async throws -> [CKSubscription] {
        guard !preview else {
            return []
        }

        return try await iCloutKit.fetchAllSubscriptions()
    }

    private func subscribeAll(toType objectType: String) async throws -> CKSubscription {
        let predicate = NSPredicate(value: true)
        return try await iCloutKit.subscribe(toType: objectType, by: predicate)
    }
}
