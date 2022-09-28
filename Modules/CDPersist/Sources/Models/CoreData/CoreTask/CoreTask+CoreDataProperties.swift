//
//  CoreTask+CoreDataProperties.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 07/08/2022.
//
//

import CoreData
import Foundation

extension CoreTask {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreTask> {
        NSFetchRequest<CoreTask>(entityName: "CoreTask")
    }

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
}

// MARK: Generated accessors for attachments

extension CoreTask {
    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: CoreAttachments)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: CoreAttachments)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSSet)
}

// MARK: Generated accessors for reminders

extension CoreTask {
    @objc(addRemindersObject:)
    @NSManaged public func addToReminders(_ value: CoreReminder)

    @objc(removeRemindersObject:)
    @NSManaged public func removeFromReminders(_ value: CoreReminder)

    @objc(addReminders:)
    @NSManaged public func addToReminders(_ values: NSSet)

    @objc(removeReminders:)
    @NSManaged public func removeFromReminders(_ values: NSSet)
}

// MARK: Generated accessors for tags

extension CoreTask {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: CoreTag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: CoreTag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}