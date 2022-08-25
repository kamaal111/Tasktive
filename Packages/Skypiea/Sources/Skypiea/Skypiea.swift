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

    /// Fetch all of the given record
    /// - Parameter objectType: `CloudKit` object
    /// - Returns: an array of records
    public func fetchAll(ofType objectType: String) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true)
        return try await fetch(ofType: objectType, withPredicate: predicate)
    }

    /// Fetch with predicate
    /// - Parameters:
    ///   - objectType: `CloudKit` object
    ///   - predicate: query
    /// - Returns: an array of records
    public func fetch(ofType objectType: String, withPredicate predicate: NSPredicate) async throws -> [CKRecord] {
        try await iCloutKit.fetch(ofType: objectType, by: predicate)
    }

    /// Singleton class for easy access of ``Skypiea/Skypiea``
    public static let shared = Skypiea()

    /// Singleton class for debugging use-cases
    public static let preview = Skypiea(preview: true)
}
