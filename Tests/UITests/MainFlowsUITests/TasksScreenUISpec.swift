//
//  TasksScreenUISpec.swift
//  MainFlowsUITests
//
//  Created by Kamaal M Farah on 28/08/2022.
//

import Quick
import XCTest
import Nimble

final class TasksScreenUISpec: QuickSpec {
    override func setUp() {
        continueAfterFailure = false
    }

    override func spec() {
        beforeEach { }

        describe("tasks screen") {
            it("goes through tasks screen in light mode") {
                let app = XCUIApplication()
                app.launch()
            }
        }
    }
}
