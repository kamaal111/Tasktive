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

    public init(
        id: UUID,
        creationDate: Date,
        updateDate: Date,
        completionDate: Date?,
        dueDate: Date,
        notes: String?,
        taskDescription: String?,
        ticked: Bool,
        title: String
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
    }

    init?(fromRecord record: CKRecord) {
        guard let id = (record[.id] as? NSString)?.uuid,
              let creationDate = record[.creationDate] as? Date,
              let updateDate = record[.updateDate] as? Date,
              let dueDate = record[.dueDate] as? Date,
              let ticked = (record[.ticked] as? Int64)?.nsNumber.boolValue,
              let title = (record[.title] as? NSString)?.string else { return nil }

        self.init(
            id: id,
            creationDate: creationDate,
            updateDate: updateDate,
            completionDate: record[.completionDate] as? Date,
            dueDate: dueDate,
            notes: (record[.notes] as? NSString)?.string,
            taskDescription: (record[.taskDescription] as? NSString)?.string,
            ticked: ticked,
            title: title
        )
    }

    public static func create(_ task: CloudTask, on context: Skypiea) async throws -> CloudTask? {
        guard let savedRecord = try await context.save(task.newRecord) else { return nil }

        return CloudTask(fromRecord: savedRecord)
    }

    var newRecord: CKRecord {
        let record = CKRecord(recordType: Self.recordType)
        record[.id] = id
        record[.creationDate] = creationDate.asNSDate
        record[.updateDate] = updateDate.asNSDate
        record[.completionDate] = completionDate?.asNSDate
        record[.dueDate] = dueDate.asNSDate
        record[.taskDescription] = taskDescription?.nsString
        record[.ticked] = ticked.int.nsNumber
        return record
    }

    enum RecordKeys: String {
        case id
        case creationDate = "creation_date"
        case updateDate = "update_date"
        case completionDate = "completion_date"
        case dueDate = "due_date"
        case notes
        case taskDescription = "task_description"
        case ticked
        case title
    }

    static let recordType = "CloudTask"
}

extension CKRecord {
    fileprivate subscript(key: CloudTask.RecordKeys) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}
