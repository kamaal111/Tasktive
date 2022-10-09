//
//  CoreReminder+CoreDataProperties.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation

extension CoreReminder {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreReminder> {
        NSFetchRequest<CoreReminder>(entityName: "CoreReminder")
    }

    @NSManaged public var time: Date
    @NSManaged public var task: CoreTask
}
