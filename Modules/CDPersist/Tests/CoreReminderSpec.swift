//
//  CoreReminderSpec.swift
//  CDPersist
//
//  Created by Kamaal M Farah on 09/10/2022.
//

import Quick
import Nimble
import XCTest
import SharedModels
@testable import CDPersist

final class CoreReminderSpec: QuickSpec {
    let viewContext = PersistenceController.preview.context

    override func spec() {
        describe("CRUD operations on CoreReminder") {
            // swiftlint:disable implicitly_unwrapped_optional
            var task: CoreTask!

            beforeEach {
                do {
                    try task?.delete(on: self.viewContext).get()
                } catch {
                    fail("failed to clear store; error='\(error)'")
                }

                let now = Date()
                let arguments = TaskArguments(
                    title: "Title",
                    taskDescription: "Description",
                    notes: "Notes\nNew Line",
                    dueDate: now
                )
                let result = CoreTask.create(with: arguments, from: self.viewContext)
                do {
                    task = try result.get()
                } catch {
                    fail("failed to make a task; error='\(error)'")
                }
            }

            context("when trying to create a CoreReminder") {
                it("returns a new reminder") {
                    let arguments = ReminderArguments(time: Date())
                    let reminder = try task.setAnReminder(with: arguments).get()

                    expect(reminder.task) == task
                    expect(reminder.time) == arguments.time
                }
            }
        }
    }
}
