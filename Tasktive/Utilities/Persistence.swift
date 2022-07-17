//
//  Persistence.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import CoreData
import ShrimpExtensions

struct PersistenceController {
    private let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: "Tasktive")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)

        let aDayInMinutes = 1440
        let arguments: [CoreTask.Arguments] = [
            .init(
                title: "Yesterdays Task",
                taskDescription: "Did stuff",
                notes: "Did some note taking",
                dueDate: Date().adding(minutes: -aDayInMinutes),
                ticked: true,
                id: UUID(uuidString: "dd74c487-8b6a-4939-943d-88e93a2f3713")!
            ),
            .init(
                title: "First Task",
                taskDescription: "Doing stuff",
                notes: "Note taking",
                dueDate: Date(),
                ticked: false,
                id: UUID(uuidString: "24b47a12-541c-401c-b2f1-82a4a1800d0b")!
            ),
            .init(
                title: "Second Task",
                taskDescription: "Doing more stuff",
                notes: "Taking more notes",
                dueDate: Date().adding(minutes: aDayInMinutes),
                ticked: false,
                id: UUID(uuidString: "19396d5b-375c-4d47-bda4-6b8d68ba5320")!
            ),
            .init(
                title: "Third Task",
                taskDescription: "Doing even more stuff",
                notes: "Taking even more notes",
                dueDate: Date().adding(minutes: aDayInMinutes * 2),
                ticked: false,
                id: UUID(uuidString: "6d98883b-a57a-4d18-82eb-4226da137615")!
            ),
        ]
        for argument in arguments {
            _ = CoreTask.create(with: argument, from: result.context)
        }

        return result
    }()
}
