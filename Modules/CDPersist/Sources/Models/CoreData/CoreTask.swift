//
//  CoreTask.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation
import ShrimpExtensions
import ManuallyManagedObject

@objc(CoreTask)
public class CoreTask: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var completionDate: Date?
    @NSManaged public var dueDate: Date
    @NSManaged public var notes: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var ticked: Bool
    @NSManaged public var title: String
    @NSManaged public var attachments: NSSet?
    @NSManaged public var reminders: NSSet?
    @NSManaged public var tags: NSSet?
    @NSManaged public var list: CoreTaskList?

    public func addToReminders(_ reminder: CoreReminder, save: Bool) {
        if reminder.task != self {
            reminder.task = self
        }

        let remindersArray = reminders?.allObjects as? [CoreReminder] ?? []
        reminders = remindersArray.appended(reminder).asNSSet

        if save {
            try? managedObjectContext?.save()
        }
    }

    public func addToReminders(_ reminder: CoreReminder) {
        addToReminders(reminder, save: true)
    }

    public static let properties: [ManagedObjectPropertyConfiguration] = baseProperties
        .concat([
            ManagedObjectPropertyConfiguration(name: \CoreTask.completionDate, type: .date, isOptional: true),
            ManagedObjectPropertyConfiguration(name: \CoreTask.dueDate, type: .date, isOptional: false),
            ManagedObjectPropertyConfiguration(name: \CoreTask.notes, type: .string, isOptional: true),
            ManagedObjectPropertyConfiguration(name: \CoreTask.taskDescription, type: .string, isOptional: true),
            ManagedObjectPropertyConfiguration(name: \CoreTask.ticked, type: .bool, isOptional: false),
            ManagedObjectPropertyConfiguration(name: \CoreTask.title, type: .string, isOptional: false),
        ])

    public static let _relationships: [_RelationshipConfiguration] = [
        _RelationshipConfiguration(
            name: "attachments",
            destinationEntity: CoreAttachments.self,
            inverseRelationshipName: "task",
            inverseRelationshipEntity: CoreTask.self,
            isOptional: true,
            relationshipType: .toMany
        ),
        _RelationshipConfiguration(
            name: "reminders",
            destinationEntity: CoreReminder.self,
            inverseRelationshipName: "task",
            inverseRelationshipEntity: CoreTask.self,
            isOptional: true,
            relationshipType: .toMany
        ),
        _RelationshipConfiguration(
            name: "tags",
            destinationEntity: CoreTag.self,
            inverseRelationshipName: "tasks",
            inverseRelationshipEntity: CoreTask.self,
            isOptional: true,
            relationshipType: .toMany
        ),
        _RelationshipConfiguration(
            name: "list",
            destinationEntity: CoreTaskList.self,
            inverseRelationshipName: "tasks",
            inverseRelationshipEntity: CoreTask.self,
            isOptional: true,
            relationshipType: .toOne
        ),
    ]
}
