//
//  TasksScreenUISpec.swift
//  MainFlowsUITests
//
//  Created by Kamaal M Farah on 28/08/2022.
//

import Quick
import XCTest
import Nimble
import TasktiveLocale

final class TasksScreenUISpec: QuickSpec {
    override func setUp() {
        continueAfterFailure = false
    }

    override func spec() {
        beforeEach { }

        describe("tasks screen") {
            for schemeMode in [CommandLineArguments.uiTestingLightMode, CommandLineArguments.uiTestingDarkMode] {
                it("goes through tasks screen using \(schemeMode.rawValue)") {
                    let app = XCUIApplication()
                    app.launchArguments.append(schemeMode.rawValue)
                    app.launchArguments.append(CommandLineArguments.previewCoredata.rawValue)
                    app.launch()

                    let circularProgressBarPrecentage = app.staticTexts
                        .findByAccessibilityIdentifiers(.circularProgressBarPrecentage)
                        .firstMatch
                    circularProgressBarPrecentage.waitForExistenceIfItDoesNotExists(timeout: 15)

                    guard circularProgressBarPrecentage.exists else {
                        fail("Circular progress bar didn't appear")
                        return
                    }
                }
            }
        }
    }
}

extension XCUIElementQuery {
    func findByAccessibilityIdentifiers(_ accessibilityIdentifiers: AccessibilityIdentifiers) -> XCUIElement {
        self[accessibilityIdentifiers.rawValue]
    }
}

extension XCUIElement {
    @discardableResult
    func waitForExistenceIfItDoesNotExists(timeout _: TimeInterval) -> Bool {
        guard !exists else { return true }

        return waitForExistence(timeout: 15)
    }
}
