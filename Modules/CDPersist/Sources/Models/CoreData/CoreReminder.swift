//
//  CoreReminder.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation
import ManuallyManagedObject

@objc(CoreReminder)
public class CoreReminder: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var time: Date
    @NSManaged public var task: CoreTask

    public static let properties: [ManagedObjectPropertyConfiguration] = baseProperties
        .concat([
            ManagedObjectPropertyConfiguration(name: \CoreReminder.time, type: .date, isOptional: false),
        ])

    public static let _relationships: [_RelationshipConfiguration] = [
        _RelationshipConfiguration(
            name: "task",
            destinationEntity: CoreTask.self,
            inverseRelationshipName: "reminders",
            inverseRelationshipEntity: CoreReminder.self,
            isOptional: false,
            relationshipType: .toOne
        ),
    ]
}
