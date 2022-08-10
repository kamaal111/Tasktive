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

    @State private var appColorAccent = AppColorAccent(appColor: .none)

    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AppColorAccentWrapper(appColorAccent: $appColorAccent) {
                ContentView()
            }
            .environment(\.managedObjectContext, persistenceController.context)
            .environmentObject(tasksViewModel)
        }
        #if os(macOS)
        Settings {
            AppColorAccentWrapper(appColorAccent: $appColorAccent) {
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
        #endif
    }
}
