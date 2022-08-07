//
//  TasktiveApp.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import SwiftUI

@main
struct TasktiveApp: App {
    @StateObject private var tasksViewModel = TasksViewModel()
    @StateObject private var settingsStackNavigator = StackNavigator()

    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
                .environmentObject(tasksViewModel)
        }
        Settings {
            NavigationStack(path: $settingsStackNavigator.path) {
                SettingsScreen()
                    .frame(
                        minWidth: Constants.UI.settingsViewMinimumSize.width,
                        minHeight: Constants.UI.settingsViewMinimumSize.height
                    )
                    .environmentObject(settingsStackNavigator)
            }
        }
    }
}
