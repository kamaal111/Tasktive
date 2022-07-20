//
//  CoreTag+CoreDataProperties.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//
//

import CoreData
import Foundation

extension CoreTag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreTag> {
        NSFetchRequest<CoreTag>(entityName: "CoreTag")
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var updateDate: Date
    @NSManaged public var value: String
    @NSManaged public var tasks: NSSet
}

// MARK: Generated accessors for tasks

extension CoreTag {
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: CoreTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: CoreTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}

extension CoreTag: Identifiable { }
