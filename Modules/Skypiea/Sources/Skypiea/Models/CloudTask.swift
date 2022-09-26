//
//  CloudTask.swift
//
//
//  Created by Kamaal M Farah on 25/08/2022.
//

import CloudKit
import Foundation
import ShrimpExtensions

public struct CloudTask: Identifiable, Hashable {
    public let id: UUID
    public let creationDate: Date
    public let updateDate: Date
    public let completionDate: Date?
    public let dueDate: Date
    public let notes: String?
    public let taskDescription: String?
    public let ticked: Bool
    public let title: String
    private var _record: CKRecord?

    public init(
        id: UUID,
        creationDate: Date,
        updateDate: Date,
        completionDate: Date?,
        dueDate: Date,
        notes: String?,
        taskDescription: String?,
        ticked: Bool,
        title: String,
        record: CKRecord? = nil
    ) {
        self.id = id
        self.creationDate = creationDate
        self.updateDate = updateDate
        self.completionDate = completionDate
        self.dueDate = dueDate
        self.notes = notes
        self.taskDescription = taskDescription
        self.ticked = ticked
        self.title = title
        self._record = record
    }
}

extension CloudTask: Cloudable {
    public var record: CKRecord {
        RecordKeys.allCases.reduce(_record ?? CKRecord(recordType: Self.recordType)) { result, key in
            switch key {
            case .id:
                result[key] = id.nsString
            case .creationDate:
                result[key] = creationDate.asNSDate
            case .updateDate:
                result[key] = updateDate.asNSDate
            case .completionDate:
                result[key] = completionDate?.asNSDate
            case .dueDate:
                result[key] = dueDate.asNSDate
            case .notes:
                result[key] = notes?.nsString
            case .taskDescription:
                result[key] = taskDescription?.nsString
            case .ticked:
                result[key] = ticked.int.nsNumber
            case .title:
                result[key] = title.nsString
            }
            return result
        }
    }

    public static let recordType = "CloudTask"

    public static func fromRecord(_ record: CKRecord) -> CloudTask? {
        guard let id = (record[.id] as? NSString)?.uuid,
              let creationDate = record[.creationDate] as? Date,
              let updateDate = record[.updateDate] as? Date,
              let dueDate = record[.dueDate] as? Date,
              let ticked = (record[.ticked] as? Int64)?.nsNumber.boolValue,
              let title = (record[.title] as? NSString)?.string else { return nil }

        return self.init(
            id: id,
            creationDate: creationDate,
            updateDate: updateDate,
            completionDate: record[.completionDate] as? Date,
            dueDate: dueDate,
            notes: (record[.notes] as? NSString)?.string,
            taskDescription: (record[.taskDescription] as? NSString)?.string,
            ticked: ticked,
            title: title,
            record: record
        )
    }
}

extension CloudTask {
    enum RecordKeys: String, CaseIterable {
        case id
        case creationDate = "kCreationDate"
        case updateDate
        case completionDate
        case dueDate
        case notes
        case taskDescription
        case ticked
        case title
    }
}

extension CKRecord {
    fileprivate subscript(key: CloudTask.RecordKeys) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}
