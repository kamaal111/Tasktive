//
//  CloudReminder.swift
//
//
//  Created by Kamaal M Farah on 11/10/2022.
//

import Logster
import CloudKit
import Foundation
import SharedModels

private let logger = Logster(from: CloudReminder.self)

public struct CloudReminder: Identifiable, Hashable, Remindable, Cloudable {
    public let id: UUID
    public let time: Date
    public let creationDate: Date
    public let updateDate: Date
    public let taskID: UUID
    private var _record: CKRecord?

    public init(id: UUID, time: Date, creationDate: Date, updateDate: Date, taskID: UUID, record: CKRecord? = nil) {
        self.id = id
        self.time = time
        self.creationDate = creationDate
        self.updateDate = updateDate
        self.taskID = taskID
        self._record = record
    }

    public var source: DataSource {
        .iCloud
    }

    public var record: CKRecord {
        RecordKeys.allCases.reduce(_record ?? CKRecord(recordType: Self.recordType)) { result, key in
            switch key {
            case .id:
                result[key] = id.nsString
            case .creationDate:
                result[key] = creationDate.asNSDate
            case .time:
                result[key] = time.asNSDate
            case .updateDate:
                result[key] = updateDate.asNSDate
            case .taskID:
                result[key] = taskID.nsString
            }
            return result
        }
    }

    public static let recordType = "CloudReminder"

    public static func fromRecord(_ record: CKRecord) -> CloudReminder? {
        guard let id = (record[.id] as? NSString)?.uuid,
              let time = record[.time] as? Date,
              let updateDate = record[.updateDate] as? Date,
              let creationDate = record[.creationDate] as? Date,
              let taskID = (record[.taskID] as? NSString)?.uuid else {
            logger.error("failed to decode record in to reminder")
            return nil
        }

        return .init(
            id: id,
            time: time,
            creationDate: creationDate,
            updateDate: updateDate,
            taskID: taskID,
            record: record
        )
    }

    public static func create(
        with arguments: ReminderArguments,
        on task: CloudTask,
        from context: Skypiea
    ) async throws -> CloudReminder? {
        try await CloudReminder.create(arguments.toCloudReminder(on: task), on: context)
    }

    enum RecordKeys: String, CaseIterable {
        case id
        case creationDate = "kCreationDate"
        case time
        case updateDate
        case taskID
    }

    func updateArguments(_ arguments: ReminderArguments) -> CloudReminder {
        .init(
            id: id,
            time: arguments.time,
            creationDate: creationDate,
            updateDate: Date(),
            taskID: taskID
        )
    }
}

extension ReminderArguments {
    fileprivate func toCloudReminder(on task: CloudTask) -> CloudReminder {
        .init(id: id ?? UUID(), time: time, creationDate: Date(), updateDate: Date(), taskID: task.id)
    }
}

extension CKRecord {
    fileprivate subscript(key: CloudReminder.RecordKeys) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}
