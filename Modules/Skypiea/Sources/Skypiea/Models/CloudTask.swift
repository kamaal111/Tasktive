//
//  CloudTask.swift
//
//
//  Created by Kamaal M Farah on 25/08/2022.
//

import Logster
import CloudKit
import Foundation
import SharedModels
import ShrimpExtensions

private let logger = Logster(from: CloudTask.self)

public struct CloudTask: Identifiable, Hashable, Taskable, Cloudable, Crudable {
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

    public func delete(on context: Skypiea) async -> Result<Void, CrudErrors> {
        do {
            try await delete(onContext: context)
        } catch {
            return .failure(.deleteFailure(context: error))
        }

        return .success(())
    }

    public func update(with arguments: TaskArguments, on context: Skypiea) async -> Result<CloudTask, CrudErrors> {
        let updatedTask: CloudTask?
        do {
            updatedTask = try await update(updateArguments(arguments), on: context)
        } catch {
            return .failure(.saveFailure(context: error))
        }

        guard let updatedTask = updatedTask else { return .failure(.updateFailure()) }

        return .success(updatedTask)
    }

    public static func create(
        with arguments: TaskArguments,
        from context: Skypiea
    ) async -> Result<CloudTask, CrudErrors> {
        let createdTask: CloudTask?
        do {
            createdTask = try await CloudTask.create(arguments.toCloudTask, on: context)
        } catch {
            logger.error(label: "failed to create cloud task", error: error)
            return .failure(.saveFailure(context: error))
        }

        guard let createdTask = createdTask else { return .failure(.saveFailure()) }

        return .success(createdTask)
    }

    public static func list(from context: Skypiea) async -> Result<[CloudTask], CrudErrors> {
        let tasks: [CloudTask]
        do {
            tasks = try await CloudTask.list(from: context)
        } catch {
            return handleFetchErrors(error)
        }
        return .success(tasks)
    }

    public static func filter(
        by predicate: NSPredicate,
        limit: Int?,
        from context: Skypiea
    ) async -> Result<[CloudTask], CrudErrors> {
        let tasks: [CloudTask]
        do {
            tasks = try await CloudTask.filter(by: predicate, limit: limit, from: context)
        } catch {
            return handleFetchErrors(error)
        }

        return .success(tasks)
    }

    public static func filter(
        by predicate: NSPredicate,
        from context: Skypiea
    ) async -> Result<[CloudTask], CrudErrors> {
        await filter(by: predicate, limit: nil, from: context)
    }

    public static func find(by predicate: NSPredicate, from context: Skypiea) async -> Result<CloudTask?, CrudErrors> {
        let task: CloudTask?
        do {
            task = try await CloudTask.find(by: predicate, from: context)
        } catch {
            return handleFetchErrors(error).map(\.first)
        }

        return .success(task)
    }

    public static func updateManyDates(
        _ tasks: [AppTask],
        date: Date,
        on context: Skypiea
    ) async -> Result<Void, CrudErrors> {
        guard !tasks.isEmpty else { return .success(()) }

        do {
            _ = try await CloudTask.updateMany(tasks.map { $0.cloudTaskWithUpdatedDueDate(date) }, on: context)
        } catch {
            logger.error(label: "error while deleting tasks", error: error)
            return .failure(.updateManyFailure(context: error))
        }

        return .success(())
    }

    public enum CrudErrors: Error {
        case saveFailure(context: Error? = nil)
        case fetchFailure(context: Error? = nil)
        case updateManyFailure(context: Error? = nil)
        case updateFailure(context: Error? = nil)
        case deleteFailure(context: Error? = nil)
        case generalFailure(message: String)
    }

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

    private func updateArguments(_ arguments: TaskArguments) -> CloudTask {
        CloudTask(
            id: id,
            creationDate: creationDate,
            updateDate: Date(),
            completionDate: arguments.completionDate,
            dueDate: arguments.dueDate,
            notes: arguments.notes,
            taskDescription: arguments.taskDescription,
            ticked: arguments.ticked,
            title: arguments.title,
            record: record
        )
    }

    private static func handleFetchErrors(_ error: Error) -> Result<[CloudTask], CrudErrors> {
        if let error = error as? CKError {
            switch error.code {
            case .unknownItem:
                logger.info("record not created yet")
                return .success([])
            default:
                break
            }
        }

        return .failure(.fetchFailure(context: error))
    }
}

extension AppTask {
    fileprivate func cloudTaskWithUpdatedDueDate(_ date: Date) -> CloudTask {
        CloudTask(
            id: id,
            creationDate: creationDate,
            updateDate: Date(),
            completionDate: completionDate,
            dueDate: date,
            notes: notes,
            taskDescription: taskDescription,
            ticked: ticked,
            title: title,
            record: record
        )
    }
}

extension TaskArguments {
    fileprivate var toCloudTask: CloudTask {
        let now = Date()

        return CloudTask(
            id: id ?? UUID(),
            creationDate: now,
            updateDate: now,
            completionDate: completionDate,
            dueDate: dueDate,
            notes: notes,
            taskDescription: taskDescription,
            ticked: ticked,
            title: title,
            record: nil
        )
    }
}

extension CKRecord {
    fileprivate subscript(key: CloudTask.RecordKeys) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}
