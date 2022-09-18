//
//  Skypiea.swift
//
//
//  Created by Kamaal M Farah on 25/08/2022.
//

import CloudKit
import ICloutKit

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
    private(set) var subscriptions: [CKSubscription] = []

    private init(preview: Bool = false) {
        self.preview = preview
    }

    public func subscripeToAll() {
        guard !preview else { return }

        // - TODO: REFACTOR THIS MESS
        fetchAllSubcriptions { (result: Result<[CKSubscription], Error>) in
            switch result {
            case let .failure(failure): print(failure)
            case let .success(success):
                let subscriptions = success
                    .filter { (subscription: CKSubscription) -> Bool in
                        guard let query = subscription as? CKQuerySubscription,
                              let recordType = query.recordType else { return false }
                        return self.subscriptionsWanted.contains(recordType)
                    }
                    .map { (subscription: CKSubscription) -> [String: CKSubscription] in
                        let recordType = (subscription as! CKQuerySubscription).recordType!
                        return [recordType.description: subscription]
                    }
                var subscriptionKeysFetched: [String] = []
                subscriptions.forEach { (subscription: [String: CKSubscription]) in
                    if let value = subscription.values.first {
                        self.subscriptions.append(value)
                    }
                    if let key = subscription.keys.first {
                        subscriptionKeysFetched.append(key)
                    }
                }
                let subscriptionKeysWanted = self.subscriptionsWanted.filter { !subscriptionKeysFetched.contains($0) }
                guard !subscriptionKeysWanted.isEmpty else { return }
                subscriptionKeysWanted.forEach { (recordType: String) in
                    self.subscribeAll(toType: recordType) { (result: Result<CKSubscription, Error>) in
                        switch result {
                        case let .failure(failure): print(failure)
                        case let .success(success): self.subscriptions.append(success)
                        }
                    }
                }
            }
        }
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

    private func fetchAllSubcriptions(completion: @escaping (Result<[CKSubscription], Error>) -> Void) {
        guard !preview else {
            completion(.success([]))
            return
        }

        iCloutKit.fetchAllSubscriptions(completion: completion)
    }

    private func subscribeAll(
        toType objectType: String,
        completion: @escaping (Result<CKSubscription, Error>) -> Void
    ) {
        let predicate = NSPredicate(value: true)
        iCloutKit.subscribe(toType: objectType, by: predicate, completion: completion)
    }
}
