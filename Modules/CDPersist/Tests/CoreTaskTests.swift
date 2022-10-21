//
//  CoreTaskTests.swift
//  CDPersistTests
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import XCTest
import SharedModels
@testable import CDPersist

final class CoreTaskTests: XCTestCase {
    let viewContext = PersistenceController.preview.context

    override func setUpWithError() throws {
        try CoreTask.clear(from: viewContext).get()
    }

    // - MARK: Creating tasks

    func testCreatesAndReturnsATask() throws {
        let now = Date()
        let arguments = TaskArguments(
            title: "Title",
            taskDescription: "Description",
            notes: "Notes\nNew Line",
            dueDate: now,
            reminders: []
        )
        let result = CoreTask.create(with: arguments, from: viewContext)
        let task = try result.get()

        XCTAssertEqual(task.title, "Title")
        XCTAssertFalse(task.ticked)
        XCTAssertEqual(task.taskDescription, "Description")
        XCTAssertEqual(task.notes, "Notes\nNew Line")
        XCTAssertEqual(task.dueDate, now)
    }

    // - MARK: Listing tasks

    func testListsEmptyTasks() throws {
        let result = CoreTask.list(from: viewContext)
        let tasks = try result.get()

        XCTAssert(tasks.isEmpty)
    }

    func testListsAllTasks() throws {
        let args: [TaskArguments] = [
            .init(
                title: "First",
                taskDescription: "Some things to think about",
                notes: "Wow notes",
                dueDate: Date(),
                reminders: []
            ),
            .init(
                title: "Second",
                taskDescription: "Other things ",
                notes: "Oh yeah",
                dueDate: Date(),
                reminders: []
            ),
        ]

        for arg in args {
            _ = CoreTask.create(with: arg, from: viewContext)
        }

        let result = CoreTask.list(from: viewContext)
        let tasks = try result.get()

        XCTAssertEqual(tasks.count, 2)

        for (index, task) in tasks.enumerated() {
            XCTAssertEqual(task.title, args[index].title)
            XCTAssertEqual(task.taskDescription, args[index].taskDescription)
            XCTAssertEqual(task.notes, args[index].notes)
            XCTAssertEqual(task.dueDate, args[index].dueDate)
        }
    }

    // - MARK: Updating tasks

    func testSuccesfullyUpdatingATask() throws {
        let arguments = TaskArguments(
            title: "Title",
            taskDescription: "Description",
            notes: "Notes\nNew Line",
            dueDate: Date().addingTimeInterval(100_000),
            reminders: []
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
            ticked: true,
            reminders: []
        )

        let updatedTask = try task.update(with: updatedArguments, on: viewContext).get()

        XCTAssertEqual(updatedTask.id, oldTaskID)
        XCTAssertEqual(updatedTask.kCreationDate, oldTaskCreationDate)

        XCTAssertNotEqual(updatedTask.dueDate, oldTaskDueDate)
        XCTAssertNotEqual(updatedTask.title, oldTaskTitle)
        XCTAssertNotEqual(updatedTask.updateDate, oldTaskUpdateTime)
        XCTAssertNotEqual(updatedTask.taskDescription, oldTaskDescription)
        XCTAssertNotEqual(updatedTask.notes, oldTaskNotes)
        XCTAssertNotEqual(updatedTask.ticked, oldTaskTicked)
    }

    // - MARK: Deleting tasks

    func testSuccessfullyDeletesATask() throws {
        let arguments = TaskArguments(
            title: "Title",
            taskDescription: nil,
            notes: nil,
            dueDate: Date(),
            reminders: []
        )
        let task = try CoreTask.create(with: arguments, from: viewContext).get()
        let tasks = try CoreTask.list(from: viewContext).get()

        XCTAssertEqual(tasks.count, 1)

        try task.delete(on: viewContext).get()
        let updatedTasks = try CoreTask.list(from: viewContext).get()

        XCTAssert(updatedTasks.isEmpty)
    }
}
