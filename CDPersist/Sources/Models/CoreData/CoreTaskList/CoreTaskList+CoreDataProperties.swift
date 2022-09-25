//
//  CoreTaskList+CoreDataProperties.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation

extension CoreTaskList {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreTaskList> {
        NSFetchRequest<CoreTaskList>(entityName: "CoreTaskList")
    }

    @NSManaged public var name: String
    @NSManaged public var listDescription: String?
    @NSManaged public var tasks: NSSet?
}

// MARK: Generated accessors for tasks

extension CoreTaskList {
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: CoreTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: CoreTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}
