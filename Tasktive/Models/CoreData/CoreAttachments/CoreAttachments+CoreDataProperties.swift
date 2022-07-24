//
//  CoreAttachments+CoreDataProperties.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//
//

import CoreData
import Foundation

extension CoreAttachments {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreAttachments> {
        NSFetchRequest<CoreAttachments>(entityName: "CoreAttachments")
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var updateDate: Date
    @NSManaged public var data: Data
    @NSManaged public var dataType: String
    @NSManaged public var task: CoreTask?
}

extension CoreAttachments: Identifiable { }