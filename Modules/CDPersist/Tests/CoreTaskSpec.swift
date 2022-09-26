//
//  CoreTaskSpec.swift
//  CDPersistTests
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Quick
import Nimble
import XCTest
import SharedModels
@testable import CDPersist

final class CoreTaskSpec: QuickSpec {
    let viewContext = PersistenceController.preview.context

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
                    let arguments = TaskArguments(
                        title: "Title",
                        taskDescription: "Description",
                        notes: "Notes\nNew Line",
                        dueDate: now
                    )
                    let result = CoreTask.create(with: arguments, from: self.viewContext)
                    let task = try result.get()

                    expect(task.title) == "Title"
                    expect(task.ticked).to(beFalse())
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
                    let args: [TaskArguments] = [
                        .init(
                            title: "First",
                            taskDescription: "Some things to think about",
                            notes: "Wow notes",
                            dueDate: Date()
                        ),
                        .init(title: "Second", taskDescription: "Other things ", notes: "Oh yeah", dueDate: Date()),
                    ]

                    for arg in args {
                        _ = CoreTask.create(with: arg, from: self.viewContext)
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

            context("when trying to update tasks") {
                it("successfully updates a task") { [self] in
                    let arguments = TaskArguments(
                        title: "Title",
                        taskDescription: "Description",
                        notes: "Notes\nNew Line",
                        dueDate: Date().addingTimeInterval(100_000)
                    )
                    let task = try CoreTask.create(with: arguments, from: viewContext).get()
                    let oldTaskTitle = task.title
                    let oldTaskID = task.id
                    let oldTaskCreationDate = task.kCreationDate
                    let oldTaskDueDate = task.dueDate
                    let oldTaskUpdateTime = task.updateDate
                    let oldTaskDescription = task.taskDescription
                    let oldTaskNotes = task.notes
                    let oldTaskTicked = task.ticked

                    let updatedArguments = TaskArguments(
                        title: "Updated",
                        taskDescription: "New description",
                        notes: "yes note",
                        dueDate: Date(),
                        ticked: true
                    )

                    let updateTaskExpectation = expectation(description: "updating task")
                    Task {
                        let updatedTask = try await task.update(with: updatedArguments, on: viewContext).get()

                        expect(updatedTask.id) == oldTaskID
                        expect(updatedTask.kCreationDate) == oldTaskCreationDate

                        expect(updatedTask.dueDate) != oldTaskDueDate
                        expect(updatedTask.title) != oldTaskTitle
                        expect(updatedTask.updateDate) != oldTaskUpdateTime
                        expect(updatedTask.taskDescription) != oldTaskDescription
                        expect(updatedTask.notes) != oldTaskNotes
                        expect(updatedTask.ticked) != oldTaskTicked

                        updateTaskExpectation.fulfill()
                    }
                    waitForExpectations(timeout: 3)
                }
            }

            context("when trying to delete a task") {
                it("get's deleted successfully") { [self] in
                    let arguments = TaskArguments(
                        title: "Title",
                        taskDescription: nil,
                        notes: nil,
                        dueDate: Date()
                    )
                    let task = try CoreTask.create(with: arguments, from: viewContext).get()
                    let tasks = try CoreTask.list(from: viewContext).get()

                    expect(tasks.count) == 1

                    let deleteTaskExpectation = expectation(description: "delete task")
                    Task {
                        _ = await task.delete(on: viewContext)

                        deleteTaskExpectation.fulfill()
                    }
                    waitForExpectations(timeout: 3)

                    let updatedTasks = try CoreTask.list(from: viewContext).get()

                    expect(updatedTasks).to(beEmpty())
                }
            }
        }
    }
}
