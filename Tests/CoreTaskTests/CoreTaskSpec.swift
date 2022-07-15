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
            context("when trying to create a CoreTask") {
                it("returns a failure due to context being misisng") {
                    self.whenTryingToCreateACoreTaskReturnsAFailureDueToContextBeingMissing()
                }

                it("returns a new task") {
                    try self.whenTryingToCreateACoreTaskReturnANewTask()
                }
            }
        }
    }
}

extension CoreTaskSpec {
    private func whenTryingToCreateACoreTaskReturnsAFailureDueToContextBeingMissing() {
        let arguments = CoreTask.Arguments(
            context: nil,
            title: "Missing context",
            taskDescription: nil,
            notes: nil,
            dueDate: Date()
        )
        let taskResult = CoreTask.create(with: arguments)

        expect({ try taskResult.get() }).to(throwError(closure: { error in
            expect(error as? CoreTask.CrudErrors) == .contextMissing
        }))
    }

    private func whenTryingToCreateACoreTaskReturnANewTask() throws {
        let now = Date()
        let arguments = CoreTask.Arguments(
            context: viewContext,
            title: "Title",
            taskDescription: "Description",
            notes: "Notes\nNew Line",
            dueDate: now
        )
        let taskResult = CoreTask.create(with: arguments)
        let task = try taskResult.get()

        expect(task.title) == "Title"
        expect(task.ticked) == false
        expect(task.taskDescription) == "Description"
        expect(task.notes) == "Notes\nNew Line"
        expect(task.dueDate) == now
    }
}
