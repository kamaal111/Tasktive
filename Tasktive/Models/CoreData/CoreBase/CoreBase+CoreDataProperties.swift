//
//  CoreBase+CoreDataProperties.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation

extension CoreBase {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreBase> {
        NSFetchRequest<CoreBase>(entityName: "CoreBase")
    }

    @NSManaged public var updateDate: Date
    @NSManaged public var creationDate: Date
    @NSManaged public var id: UUID
}

extension CoreBase: Identifiable { }
