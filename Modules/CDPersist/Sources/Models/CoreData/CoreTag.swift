//
//  CoreTag.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation
import ManuallyManagedObject

@objc(CoreTag)
public class CoreTag: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var value: String
    @NSManaged public var tasks: NSSet?

    public static let properties: [ManagedObjectPropertyConfiguration] = baseProperties
        .concat([
            ManagedObjectPropertyConfiguration(name: \CoreTag.value, type: .string, isOptional: false),
        ])

    public static let _relationships: [_RelationshipConfiguration] = [
        _RelationshipConfiguration(
            name: "tasks",
            destinationEntity: CoreTask.self,
            inverseRelationshipName: "tags",
            inverseRelationshipEntity: CoreTag.self,
            isOptional: true,
            relationshipType: .toMany
        ),
    ]
}
