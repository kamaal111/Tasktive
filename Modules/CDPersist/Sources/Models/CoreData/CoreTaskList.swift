//
//  CoreTaskList.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation
import ManuallyManagedObject

@objc(CoreTaskList)
public class CoreTaskList: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var listDescription: String?
    @NSManaged public var tasks: NSSet?

    public static let properties: [ManagedObjectPropertyConfiguration] = baseProperties
        .concat([
            ManagedObjectPropertyConfiguration(name: \CoreTaskList.name, type: .string, isOptional: false),
            ManagedObjectPropertyConfiguration(name: \CoreTaskList.listDescription, type: .string, isOptional: true),
        ])

    public static let _relationships: [_RelationshipConfiguration] = [
        _RelationshipConfiguration(
            name: "tasks",
            destinationEntity: CoreTask.self,
            inverseRelationshipName: "list",
            inverseRelationshipEntity: CoreTaskList.self,
            isOptional: true,
            relationshipType: .toMany
        ),
    ]
}
