//
//  AppTask.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import CloudKit
import Foundation

public struct AppTask: Hashable, Identifiable {
    public let id: UUID
    public var title: String
    public var taskDescription: String?
    public var notes: String?
    public var ticked: Bool
    public var dueDate: Date
    public var completionDate: Date?
    public let creationDate: Date
    public let source: DataSource
    public var record: CKRecord?

    public init(
        id: UUID,
        title: String,
        taskDescription: String? = nil,
        notes: String? = nil,
        ticked: Bool,
        dueDate: Date,
        completionDate: Date?,
        creationDate: Date,
        source: DataSource,
        record: CKRecord? = nil
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.notes = notes
        self.ticked = ticked
        self.dueDate = dueDate
        self.completionDate = completionDate
        self.creationDate = creationDate
        self.source = source
        self.record = record
    }

    public var coreTaskArguments: TaskArguments {
        .init(
            title: title,
            taskDescription: taskDescription,
            notes: notes,
            dueDate: dueDate,
            ticked: ticked,
            id: id,
            completionDate: completionDate
        )
    }

    public func toggleCoreTaskTickArguments(with newTickState: Bool) -> TaskArguments {
        .init(
            title: title,
            taskDescription: taskDescription,
            notes: notes,
            dueDate: dueDate,
            ticked: newTickState,
            id: id,
            completionDate: newTickState ? Date() : nil
        )
    }
}
