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

    /// Subscribe to all iCloud subscriptions to recieve changes notifications.
    public func subscripeToAll() async throws {
        guard !preview else { return }

        let fetchedSubscriptions = try await fetchAllSubcriptions()
        let fetchedSubscriptionsAsRecordTypes: [CKRecord.RecordType] = fetchedSubscriptions.compactMap {
            guard let query = $0 as? CKQuerySubscription else { return nil }
            return query.recordType
        }

        let subscriptionsToSubscribeTo = subscriptionsWanted.filter { !fetchedSubscriptionsAsRecordTypes.contains($0) }

        var subscribedSubsctiptions: [CKSubscription] = []
        for subscriptionToSubscribeTo in subscriptionsToSubscribeTo {
            let subscribedSubscription: CKSubscription
            do {
                subscribedSubscription = try await subscribeAll(toType: subscriptionToSubscribeTo)
            } catch {
                logger.error(
                    label: "failed to subscribe to \(subscriptionToSubscribeTo) iCloud subscription",
                    error: error
                )
                continue
            }

            subscribedSubsctiptions.append(subscribedSubscription)
        }

        subscriptions = fetchedSubscriptions + subscribedSubsctiptions
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

        var items: [CKRecord] = []
        do {
            items = try await iCloutKit.fetch(ofType: objectType, by: predicate)
        } catch {
            throw error
        }

        var recordsMappedByID: [NSString: CKRecord] = [:]
        var recordsToDelete: [CKRecord] = []
        for item in items {
            if let id = item["id"] as? NSString {
                if let recordToDelete = recordsMappedByID[id] {
                    recordsToDelete.append(recordToDelete)
                } else {
                    recordsMappedByID[id] = item
                }
            }
        }

        let deletedTasks = try await iCloutKit.deleteMultiple(recordsToDelete)
        if !deletedTasks.isEmpty {
            logger.info("deleted cloud tasks; \(deletedTasks)")
        }

        return recordsMappedByID.values.asArray()
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
        logger.info("subscribing to all \(objectType) iCloud subscriptions")
        return try await iCloutKit.subscribe(toType: objectType, by: predicate)
    }
}
