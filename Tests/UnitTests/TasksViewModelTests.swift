//
//  TasksViewModelTests.swift
//  TasktiveTests
//
//  Created by Kamaal M Farah on 18/09/2022.
//

import Quick
import Nimble
import XCTest
import CDPersist
import Foundation
@testable import Tasktive

final class TasksViewModelTests: QuickSpec {
    let viewContext = PersistenceController.preview.context

    override func spec() {
        beforeEach { [self] in
            do {
                try CoreTask.clear(from: viewContext).get()
            } catch {
                fail("failed to clear store; error='\(error)'")
            }
        }

        describe("updateTask") {
            it("does not update due to an invalid title") { [self] in
                let tasksViewModel = TasksViewModel(preview: true)
                let now = Date()
                let taskOfNow = try createTask(forDate: now)

                let gettingTasksExpectation = expectation(description: "Getting tasks")
                Task {
                    do {
                        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
                    } catch {
                        fail("failed to get tasks; error='\(error)'")
                    }
                    gettingTasksExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)

                let updateTaskExpectation = expectation(description: "Updating a task")
                Task {
                    var arguments = taskOfNow.arguments
                    arguments.title = ""

                    let result = await tasksViewModel.updateTask(taskOfNow.asAppTask, with: arguments)
                    switch result {
                    case .success:
                        fail("not supposed to succeed")
                        return
                    case let .failure(failure):
                        expect(failure) == .invalidTitle
                    }
                    updateTaskExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)
            }

            it("updates a task with the same due date") { [self] in
                let tasksViewModel = TasksViewModel(preview: true)
                let now = Date()
                let taskOfNow = try createTask(forDate: now)

                let gettingTasksExpectation = expectation(description: "Getting tasks")
                Task {
                    do {
                        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
                    } catch {
                        fail("failed to get tasks; error='\(error)'")
                    }
                    gettingTasksExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)

                let updateTaskExpectation = expectation(description: "Updating a task")
                Task {
                    let arguments = taskOfNow.arguments

                    let result = await tasksViewModel.updateTask(taskOfNow.asAppTask, with: arguments)
                    switch result {
                    case .success:
                        break
                    case let .failure(failure):
                        fail("failed to update task; error='\(failure)'")
                        return
                    }

                    updateTaskExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)

                let tasksForNow = tasksViewModel.tasksForDate(now)
                expect(tasksForNow.count) == 1
                expect(tasksForNow[0].id) == taskOfNow.id
            }

            it("updates a task with a updated due date") { [self] in
                let tasksViewModel = TasksViewModel(preview: true)
                let now = Date()
                let tomorrow = now.incrementByDays(1)
                let taskOfNow = try createTask(forDate: now)

                let gettingTasksExpectation = expectation(description: "Getting tasks")
                Task {
                    do {
                        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
                        try await tasksViewModel.getTasks(from: [.coreData], for: tomorrow).get()
                    } catch {
                        fail("failed to get tasks; error='\(error)'")
                    }
                    gettingTasksExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)

                let updateTaskExpectation = expectation(description: "Updating a task")
                Task {
                    var arguments = taskOfNow.arguments
                    arguments.dueDate = tomorrow

                    let result = await tasksViewModel.updateTask(taskOfNow.asAppTask, with: arguments)
                    switch result {
                    case .success:
                        break
                    case let .failure(failure):
                        fail("failed to update task; error='\(failure)'")
                        return
                    }

                    updateTaskExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)

                let refreshingTasksExpectation = expectation(description: "Refreshing tasks")
                Task {
                    do {
                        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
                        try await tasksViewModel.getTasks(from: [.coreData], for: tomorrow).get()
                    } catch {
                        fail("failed to get tasks; error='\(error)'")
                    }
                    refreshingTasksExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)

                let tasksForNow = tasksViewModel.tasksForDate(now)
                expect(tasksForNow.isEmpty).to(beTrue())

                print("tasksViewModel.tasks", tasksViewModel.tasks)

                let tasksForTomorrow = tasksViewModel.tasksForDate(tomorrow)
                expect(tasksForTomorrow.count) == 1
                expect(tasksForTomorrow[0].dueDate) == tomorrow
                expect(tasksForTomorrow[0].id) == taskOfNow.id
            }
        }

        describe("getTasks") {
            it("gets todays tasks") { [self] in
                let tasksViewModel = TasksViewModel(preview: true)
                let now = Date()
                let taskOfNow = try createTask(forDate: now)
                let yesterday = now.incrementByDays(-1)
                let taskOfYeserday = try createTask(forDate: yesterday)

                let gettingTasksExpectation = expectation(description: "Getting tasks")
                Task {
                    do {
                        try await tasksViewModel.getTasks(from: [.coreData], for: now).get()
                        try await tasksViewModel.getTasks(from: [.coreData], for: yesterday).get()
                    } catch {
                        fail("failed to get tasks; error='\(error)'")
                    }
                    gettingTasksExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)

                expect(tasksViewModel.allTasksSortedByCreationDate.count) == 2

                let todaysTasks = tasksViewModel.tasksForDate(now)
                expect(todaysTasks.count) == 1
                expect(todaysTasks.contains(where: { $0.id == taskOfNow.id })).to(beTrue())
                expect(todaysTasks.contains(where: { $0.id == taskOfYeserday.id })).to(beFalse())

                let yesterdaysTasks = tasksViewModel.tasksForDate(yesterday)
                expect(yesterdaysTasks.count) == 1
                expect(yesterdaysTasks.contains(where: { $0.id == taskOfNow.id })).to(beFalse())
                expect(yesterdaysTasks.contains(where: { $0.id == taskOfYeserday.id })).to(beTrue())
            }
        }

        describe("getInitialTasks") {
            it("gets todays tasks and previous tasks that have not been completed yet") { [self] in
                let tasksViewModel = TasksViewModel(preview: true)

                let now = Date()
                let taskOfNow = try createTask(forDate: now)
                let taskOfYeserday = try createTask(forDate: now.incrementByDays(-1))

                let gettingTasksExpectation = expectation(description: "Getting tasks")
                Task {
                    do {
                        try await tasksViewModel.getInitialTasks(from: [.coreData]).get()
                    } catch {
                        fail("failed to get initial tasks; error='\(error)'")
                    }
                    gettingTasksExpectation.fulfill()
                }
                waitForExpectations(timeout: 3)

                expect(tasksViewModel.allTasksSortedByCreationDate.count) == 2

                let todaysTasks = tasksViewModel.tasksForDate(now)
                expect(todaysTasks.count) == 2
                expect(todaysTasks.contains(where: { $0.id == taskOfNow.id })).to(beTrue())
                expect(todaysTasks.contains(where: { $0.id == taskOfYeserday.id })).to(beTrue())
            }
        }
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
            completionDate: ticked ? date : nil
        )
        return try CoreTask.create(with: arguments, from: viewContext).get()
    }
}
