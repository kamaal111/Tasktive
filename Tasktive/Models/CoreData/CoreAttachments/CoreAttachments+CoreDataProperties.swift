//
//  CoreAttachments+CoreDataProperties.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation

extension CoreAttachments {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreAttachments> {
        NSFetchRequest<CoreAttachments>(entityName: "CoreAttachments")
    }

    @NSManaged public var data: Data
    @NSManaged public var dataType: String
    @NSManaged public var task: CoreTask
}
