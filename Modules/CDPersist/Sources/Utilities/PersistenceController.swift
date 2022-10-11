//
//  PersistenceController.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Logster
import CoreData
import SharedModels
import ShrimpExtensions

private let logger = Logster(from: PersistenceController.self)

/// Utility class to handle core data operations.
public class PersistenceController {
    private let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        guard let bundle = Bundle(identifier: Constants.bundleIdentifier) else {
            fatalError("framework container not found")
        }

        let containerName = "Tasktive"
        guard let containerURL = bundle.url(forResource: containerName, withExtension: "momd") else {
            fatalError("container url not found")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: containerURL) else {
            fatalError("managed object model")
        }

        self.container = NSPersistentContainer(name: containerName, managedObjectModel: managedObjectModel)

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else if let defaultURL = container.persistentStoreDescriptions.first?.url {
            let defaultStore = NSPersistentStoreDescription(url: defaultURL)
            defaultStore.configuration = "Default"
            defaultStore.shouldMigrateStoreAutomatically = false
            defaultStore.shouldInferMappingModelAutomatically = true
        } else {
            fatalError("default url not found")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    /// The main queue’s managed object context.
    public var context: NSManagedObjectContext {
        container.viewContext
    }

    /// Main singleton instance to handle core data operations.
    public static let shared = PersistenceController()

    /// Preview singleton to be used for debugging or previewing core data operations.
    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)

        let aDayInMinutes = 1440
        let arguments: [TaskArguments] = [
            .init(
                title: "Yesterdays Task",
                taskDescription: "Did stuff",
                notes: "Did some note taking",
                dueDate: Date().adding(minutes: -aDayInMinutes),
                ticked: true,
                id: UUID(uuidString: "dd74c487-8b6a-4939-943d-88e93a2f3713")!,
                completionDate: Date().adding(minutes: -aDayInMinutes),
                reminders: []
            ),
            .init(
                title: "First Task",
                taskDescription: "Doing stuff",
                notes: "Note taking",
                dueDate: Date(),
                ticked: false,
                id: UUID(uuidString: "24b47a12-541c-401c-b2f1-82a4a1800d0b")!,
                completionDate: nil,
                reminders: []
            ),
            .init(
                title: "Second of today",
                taskDescription: "Doing stuff",
                notes: "Note taking",
                dueDate: Date(),
                ticked: true,
                id: UUID(uuidString: "29bb34c1-d8ba-48a5-b48a-059d7d2c3a62")!,
                completionDate: Date(),
                reminders: []
            ),
            .init(
                title: "Second Task",
                taskDescription: "Doing more stuff",
                notes: "Taking more notes",
                dueDate: Date().adding(minutes: aDayInMinutes),
                ticked: false,
                id: UUID(uuidString: "19396d5b-375c-4d47-bda4-6b8d68ba5320")!,
                completionDate: nil,
                reminders: []
            ),
            .init(
                title: "Third Task",
                taskDescription: "Doing even more stuff",
                notes: "Taking even more notes",
                dueDate: Date().adding(minutes: aDayInMinutes * 2),
                ticked: false,
                id: UUID(uuidString: "6d98883b-a57a-4d18-82eb-4226da137615")!,
                completionDate: nil,
                reminders: []
            ),
        ]
        for argument in arguments {
            _ = CoreTask.create(with: argument, from: result.context)
        }

        return result
    }()
}
