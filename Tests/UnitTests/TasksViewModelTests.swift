//
//  TasksViewModelTests.swift
//  TasktiveTests
//
//  Created by Kamaal M Farah on 18/09/2022.
//

import Quick
import Nimble
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
