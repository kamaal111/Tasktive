//
//  CoreReminderTests.swift
//  TasktiveTests
//
//  Created by Kamaal M Farah on 21/10/2022.
//

import XCTest
import SharedModels
@testable import CDPersist

final class CoreReminderTests: XCTestCase {
    let viewContext = PersistenceController.preview.context
    // swiftlint:disable implicitly_unwrapped_optional
    var task: CoreTask!

    override func setUpWithError() throws {
        try task?.delete(on: viewContext).get()

        let now = Date()
        let arguments = TaskArguments(
            title: "Title",
            taskDescription: "Description",
            notes: "Notes\nNew Line",
            dueDate: now,
            reminders: []
        )

        task = try CoreTask.create(with: arguments, from: viewContext).get()
    }

    // - MARK: Creating reminders

    func testCreatingAReminder() throws {
        let arguments = ReminderArguments(time: Date(), id: nil, taskID: task.id)
        var taskArguments = task.arguments
        taskArguments.reminders = [arguments]
        let reminder = try task.update(with: taskArguments, on: viewContext).get().remindersArray.first

        XCTAssertEqual(task.remindersArray.count, 1)
        XCTAssertEqual(task.remindersArray.first, reminder)
        XCTAssertEqual(reminder?.taskID, task.id)
        XCTAssertEqual(reminder?.time, arguments.time)
    }

    // - MARK: Deleting reminders

    func testSuccefullyDeletedAReminder() throws {
        let arguments = ReminderArguments(time: Date(), id: nil, taskID: task.id)
        var taskArguments = task.arguments
        taskArguments.reminders = [arguments]
        let updatedTask = try task.update(with: taskArguments, on: viewContext).get()
        let reminder = (updatedTask.reminders?.allObjects as? [CoreReminder])?.first

        try reminder?.delete(on: viewContext).get()
        XCTAssert(task.remindersArray.isEmpty)
    }

    func testCascadingDeleteReminderOnTaskDeletion() throws {
        let arguments = ReminderArguments(time: Date(), id: nil, taskID: task.id)
        var taskArguments = task.arguments
        taskArguments.reminders = [arguments]
        let updatedTask = try task.update(with: taskArguments, on: viewContext).get()
        let reminder = (updatedTask.reminders?.allObjects as? [CoreReminder])?.first
        let reminderID = reminder!.id.uuidString as NSString
        let predicate = NSPredicate(format: "id == %@", reminderID)

        XCTAssertEqual(try CoreReminder.find(by: predicate, from: viewContext).get(), reminder)

        try task.delete(on: viewContext).get()

        XCTAssertNil(try CoreReminder.find(by: predicate, from: viewContext).get())
    }
}
