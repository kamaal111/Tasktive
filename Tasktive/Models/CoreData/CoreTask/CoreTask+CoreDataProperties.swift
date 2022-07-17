//
//  CoreTask+CoreDataProperties.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//
//

import CoreData
import Foundation

extension CoreTask {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreTask> {
        NSFetchRequest<CoreTask>(entityName: "CoreTask")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged public var notes: String?
    @NSManaged public var creationDate: Date
    @NSManaged public var updateDate: Date
    @NSManaged public var ticked: Bool
    @NSManaged public var dueDate: Date
    @NSManaged public var completionDate: Date?
}

extension CoreTask: Identifiable { }
