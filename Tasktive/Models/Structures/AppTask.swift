//
//  AppTask.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import CloudKit
import Foundation

struct AppTask: Hashable, Identifiable {
    let id: UUID
    var title: String
    var taskDescription: String?
    var notes: String?
    var ticked: Bool
    var dueDate: Date
    var completionDate: Date?
    let creationDate: Date
    let source: DataSource
    var record: CKRecord?

    init(
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

    var coreTaskArguments: TaskArguments {
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

    func toggleCoreTaskTickArguments(with newTickState: Bool) -> TaskArguments {
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

extension AppTask: Gridable {
    var dictionary: [String: String] {
        [
            "ID": idString,
            "Title": title,
            "Ticked": ticked ? "Yes" : "No",
            "Due date": Self.dateFormatter.string(from: dueDate),
        ]
    }

    var idString: String {
        id.uuidString
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
