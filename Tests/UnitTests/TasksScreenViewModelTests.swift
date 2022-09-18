//
//  TasksScreenViewModelTests.swift
//  TasktiveTests
//
//  Created by Kamaal M Farah on 13/09/2022.
//

import Quick
import Nimble
@testable import Tasktive

final class TasksScreenViewModelTests: QuickSpec {
    override func spec() {
        var viewModel: TasksScreen.ViewModel!

        describe("disableNewTaskSubmitButton") {
            beforeEach {
                viewModel = .init()
            }

            it("is disabled when new title is empty") {
                let disabled = viewModel.disableNewTaskSubmitButton(isConnectedToNetwork: false)

                expect(viewModel.newTitle).to(beEmpty())
                expect(disabled).to(beTrue())
            }

            it("is not disabled when not connected to network and using core data as data store") {
                viewModel.newTitle = "not empty"
                viewModel.currentSource = .coreData

                let disabled = viewModel.disableNewTaskSubmitButton(isConnectedToNetwork: false)

                expect(disabled).to(beFalse())
            }

            it("is disabled when not connected to network and using iCloud as data store") {
                viewModel.newTitle = "not empty"
                viewModel.currentSource = .iCloud

                let disabled = viewModel.disableNewTaskSubmitButton(isConnectedToNetwork: false)

                expect(disabled).to(beTrue())
            }

            it("is not disabled when connected to network and data store is core data") {
                viewModel.newTitle = "not empty"
                viewModel.currentSource = .coreData

                let disabled = viewModel.disableNewTaskSubmitButton(isConnectedToNetwork: true)

                expect(disabled).to(beFalse())
            }

            it("is not disabled when connected to network and data store is iCloud") {
                viewModel.newTitle = "not empty"
                viewModel.currentSource = .iCloud

                let disabled = viewModel.disableNewTaskSubmitButton(isConnectedToNetwork: true)

                expect(disabled).to(beFalse())
            }
        }
    }
}
