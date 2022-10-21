//
//  TasksViewModelTests.swift
//  TasktiveTests
//
//  Created by Kamaal M Farah on 18/09/2022.
//

import XCTest
import CDPersist
import SharedModels
@testable import Tasktive

final class TasksViewModelTests: XCTestCase {
    let viewContext = PersistenceController.preview.context

    override func setUpWithError() throws {
        try CoreTask.clear(from: viewContext).get()
    }

    // - MARK: Update task

    func testDoesNotUpdateDueToAnInvalidTitle() async throws {
        let tasksViewModel = TasksViewModel(preview: true)
        let now = Date()
        let taskOfNow = try createTask(forDate: now)

        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()

        var arguments = taskOfNow.arguments
        arguments.title = ""

        let result = await tasksViewModel.updateTask(taskOfNow.toAppTask, with: arguments, on: .coreData)
        switch result {
        case .success:
            XCTFail("not supposed to succeed")
            return
        case let .failure(failure):
            XCTAssertEqual(failure, .invalidTitle)
        }
    }

    func testUpdateWithSameDueDate() async throws {
        let tasksViewModel = TasksViewModel(preview: true)
        let now = Date()
        let taskOfNow = try createTask(forDate: now)

        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
        let arguments = taskOfNow.arguments
        try await tasksViewModel.updateTask(taskOfNow.toAppTask, with: arguments, on: .coreData).get()

        let tasksForNow = tasksViewModel.tasksForDate(now)
        XCTAssertEqual(tasksForNow.count, 1)
        XCTAssertEqual(tasksForNow.first?.id, taskOfNow.id)
    }

    func testUpdateWithUpdatedDueDate() async throws {
        let tasksViewModel = TasksViewModel(preview: true)
        let now = Date()
        let tomorrow = now.incrementByDays(1)
        let taskOfNow = try createTask(forDate: now)

        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
        try await tasksViewModel.getTasks(from: [.coreData], for: tomorrow).get()

        var arguments = taskOfNow.arguments
        arguments.dueDate = tomorrow

        try await tasksViewModel.updateTask(taskOfNow.toAppTask, with: arguments, on: .coreData).get()

        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
        try await tasksViewModel.getTasks(from: [.coreData], for: tomorrow).get()

        let tasksForNow = tasksViewModel.tasksForDate(now)
        XCTAssert(tasksForNow.isEmpty)

        let tasksForTomorrow = tasksViewModel.tasksForDate(tomorrow)
        XCTAssertEqual(tasksForTomorrow.count, 1)
        XCTAssertEqual(tasksForTomorrow.first?.dueDate, tomorrow)
        XCTAssertEqual(tasksForTomorrow.first?.id, taskOfNow.id)
    }

    // - MARK: Fetch tasks

    func testGetTodaysTasks() async throws {
        let tasksViewModel = TasksViewModel(preview: true)
        let now = Date()
        let taskOfNow = try createTask(forDate: now)
        let yesterday = now.incrementByDays(-1)
        let taskOfYeserday = try createTask(forDate: yesterday)

        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
        try await tasksViewModel.getTasks(from: [.coreData], for: yesterday).get()

        XCTAssertEqual(tasksViewModel.allTasksSortedByCreationDate.count, 2)

        let todaysTasks = tasksViewModel.tasksForDate(now)
        XCTAssertEqual(todaysTasks.count, 1)
        XCTAssert(todaysTasks.contains(where: { $0.id == taskOfNow.id }))
        XCTAssertFalse(todaysTasks.contains(where: { $0.id == taskOfYeserday.id }))

        let yesterdaysTasks = tasksViewModel.tasksForDate(yesterday)
        XCTAssertEqual(yesterdaysTasks.count, 1)
        XCTAssertFalse(yesterdaysTasks.contains(where: { $0.id == taskOfNow.id }))
        XCTAssert(yesterdaysTasks.contains(where: { $0.id == taskOfYeserday.id }))
    }

    func testGetTodaysTasksAndOutdatedTasks() async throws {
        let tasksViewModel = TasksViewModel(preview: true)

        let now = Date()
        let taskOfNow = try createTask(forDate: now)
        let taskOfYeserday = try createTask(forDate: now.incrementByDays(-1))

        try await tasksViewModel.getInitialTasks(from: [.coreData]).get()

        XCTAssertEqual(tasksViewModel.allTasksSortedByCreationDate.count, 2)

        let todaysTasks = tasksViewModel.tasksForDate(now)
        XCTAssertEqual(todaysTasks.count, 2)
        XCTAssert(todaysTasks.contains(where: { $0.id == taskOfNow.id }))
        XCTAssert(todaysTasks.contains(where: { $0.id == taskOfYeserday.id }))
    }

    @discardableResult
    private func createTask(forDate date: Date, ticked: Bool = false) throws -> CoreTask {
        let arguments = TaskArguments(
            title: "Title",
            taskDescription: "Description",
            notes: "Notes\nNew Line",
            dueDate: date,
            ticked: ticked,
            id: UUID(),
            completionDate: ticked ? date : nil,
            reminders: []
        )
        return try CoreTask.create(with: arguments, from: viewContext).get()
    }
}
