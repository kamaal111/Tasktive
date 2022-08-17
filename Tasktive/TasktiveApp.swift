//
//  TasktiveApp.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import SwiftUI
import SettingsUI

/// &#128511;
@main
struct TasktiveApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #else
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif

    @StateObject private var tasksViewModel = TasksViewModel()
    @StateObject private var settingsStackNavigator = StackNavigator(screen: .settings)
    @StateObject private var theme = Theme()

    @State private var currentScreen = STARTING_SCREEN

    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: .currentScreenChanged), perform: { notification in
                    guard let currentScreen = notification.object as? NamiNavigator.Screens else { return }

                    self.currentScreen = currentScreen
                })
            #if os(iOS)
                .onShake(perform: navigateToPlayground)
            #endif
                .accentColor(theme.currentAccentColor)
                .environment(\.managedObjectContext, persistenceController.context)
                .environmentObject(tasksViewModel)
                .environmentObject(theme)
        }
        #if DEBUG
            .commands(content: {
                CommandGroup(replacing: .help) {
                    Button(action: navigateToPlayground) {
                        Text("Playground")
                    }
                    .keyboardShortcut("D", modifiers: [.command, .shift])
                }
            })
        #endif
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

    /// Send notification to ``StackNavigator`` to navigate to playground where there are no laws 🤠
    private func navigateToPlayground() {
        #if DEBUG
        NotificationCenter.default.post(name: .navigateToPlayground, object: currentScreen)
        #endif
    }
}
