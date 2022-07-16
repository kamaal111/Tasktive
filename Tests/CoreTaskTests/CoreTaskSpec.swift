//
//  CoreTaskSpec.swift
//  CoreTaskTests
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import Quick
import Nimble
import Foundation
@testable import Tasktive

final class CoreTaskSpec: QuickSpec {
    let viewContext = PersistenceController.preview.container.viewContext

    override func spec() {
        describe("CRUD operations on CoreTask") {
            beforeEach {
                do {
                    try CoreTask.clear(from: self.viewContext).get()
                } catch {
                    fail("failed to clear store; error='\(error)'")
                }
            }

            context("when trying to create a CoreTask") {
                it("returns a new task") {
                    let now = Date()
                    let arguments = CoreTask.Arguments(
                        title: "Title",
                        taskDescription: "Description",
                        notes: "Notes\nNew Line",
                        dueDate: now
                    )
                    let result = CoreTask.create(with: arguments, from: self.viewContext)
                    let task = try result.get()

                    expect(task.title) == "Title"
                    expect(task.ticked) == false
                    expect(task.taskDescription) == "Description"
                    expect(task.notes) == "Notes\nNew Line"
                    expect(task.dueDate) == now
                }
            }

            context("when trying to list tasks") {
                it("returns no tasks because nothing has been saved yet") {
                    let result = CoreTask.list(from: self.viewContext)
                    let tasks = try result.get()

                    expect(tasks).to(beEmpty())
                }

                it("returns couple of tasks that have been saved") {
                    let args: [CoreTask.Arguments] = [
                        .init(
                            title: "First",
                            taskDescription: "Some things to think about",
                            notes: "Wow notes",
                            dueDate: Date()
                        ),
                        .init(title: "Second", taskDescription: "Other things ", notes: "Oh yeah", dueDate: Date()),
                    ]

                    for arg in args {
                        _ = try CoreTask.create(with: arg, from: self.viewContext).get()
                    }

                    let result = CoreTask.list(from: self.viewContext)
                    let tasks = try result.get()

                    expect(tasks.count) == 2

                    for (index, task) in tasks.enumerated() {
                        expect(task.title) == args[index].title
                        expect(task.taskDescription) == args[index].taskDescription
                        expect(task.notes) == args[index].notes
                        expect(task.dueDate) == args[index].dueDate
                    }
                }
            }
        }
    }
}
