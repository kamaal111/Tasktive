//
//  CoreReminder+CoreDataProperties.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//
//

import CoreData
import Foundation

extension CoreReminder {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreReminder> {
        NSFetchRequest<CoreReminder>(entityName: "CoreReminder")
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var updateDate: Date
    @NSManaged public var title: String
    @NSManaged public var reminderDescription: String?
    @NSManaged public var time: Date
    @NSManaged public var task: CoreTask?
}

extension CoreReminder: Identifiable { }
