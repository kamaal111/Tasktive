//
//  CoreAttachments.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 25/09/2022.
//
//

import CoreData
import Foundation
import ManuallyManagedObject

@objc(CoreAttachments)
public class CoreAttachments: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var data: Data
    @NSManaged public var dataType: String
    @NSManaged public var task: CoreTask

    public static let properties: [ManagedObjectPropertyConfiguration] = baseProperties
        .concat([
            ManagedObjectPropertyConfiguration(name: \CoreAttachments.data, type: .data, isOptional: false),
            ManagedObjectPropertyConfiguration(name: \CoreAttachments.dataType, type: .string, isOptional: false),
        ])

    public static let _relationships: [_RelationshipConfiguration] = [
        _RelationshipConfiguration(
            name: "task",
            destinationEntity: CoreTask.self,
            inverseRelationshipName: "attachments",
            inverseRelationshipEntity: CoreAttachments.self,
            isOptional: false,
            relationshipType: .toOne
        ),
    ]
}
