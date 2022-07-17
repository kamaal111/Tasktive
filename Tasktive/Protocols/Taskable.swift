//
//  Taskable.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import Foundation

protocol Taskable {
    var id: UUID { get set }
    var title: String { get set }
    var taskDescription: String? { get set }
    var notes: String? { get set }
    var ticked: Bool { get set }
    var dueDate: Date { get set }
    var completionDate: Date? { get set }
    var source: TaskSource { get }
}

enum TaskSource {
    case coreData
}

extension Taskable {
    var asAppTask: AppTask {
        .init(id: id, title: title, ticked: ticked, dueDate: dueDate, completionDate: completionDate, source: source)
    }
}
