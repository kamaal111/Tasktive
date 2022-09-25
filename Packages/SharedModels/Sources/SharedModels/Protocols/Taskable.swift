//
//  Taskable.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Foundation

public protocol Taskable {
    var id: UUID { get }
    var title: String { get }
    var taskDescription: String? { get }
    var notes: String? { get }
    var ticked: Bool { get }
    var dueDate: Date { get }
    var completionDate: Date? { get }
    var creationDate: Date { get }
    var source: DataSource { get }
}

extension Taskable {
    public var asAppTask: AppTask {
        .init(
            id: id,
            title: title,
            ticked: ticked,
            dueDate: dueDate,
            completionDate: completionDate,
            creationDate: creationDate,
            source: source
        )
    }
}
