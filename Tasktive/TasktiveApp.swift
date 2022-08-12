//
//  TasktiveApp.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import SwiftUI
import SettingsUI

@main
struct TasktiveApp: App {
    @StateObject private var tasksViewModel = TasksViewModel()
    @StateObject private var settingsStackNavigator = StackNavigator()
    @StateObject private var theme = Theme()

    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(theme.currentAccentColor)
                .environment(\.managedObjectContext, persistenceController.context)
                .environmentObject(tasksViewModel)
                .environmentObject(theme)
        }
        #if os(macOS)
        Settings {
            NavigationStack(path: $settingsStackNavigator.path) {
                SettingsScreen()
                    .accentColor(theme.currentAccentColor)
                    .frame(
                        minWidth: Constants.UI.settingsViewMinimumSize.width,
                        minHeight: Constants.UI.settingsViewMinimumSize.height
                    )
                    .environmentObject(settingsStackNavigator)
            }
            .environmentObject(theme)
        }
        #endif
    }
}
