//
//  Environment.swift
//
//
//  Created by Kamaal M Farah on 17/09/2022.
//

import Foundation

/// Object to hold the environment variables.
public enum Environment {
    /// The features that are enabled or disabled.
    public enum Features {
        #if targetEnvironment(simulator)
        /// If iCloud syncing is enabled or not.
        public static let iCloudSyncing = false
        #else
        /// If iCloud syncing is enabled or not.
        public static let iCloudSyncing = true
        #endif
        /// If task reminders are enabled or not.
        public static let taskReminders = true
    }

    /// Command line arguments driven by the current schemes configuration.
    public enum CommandLineArguments: String {
        case uiTestingLightMode = "ui_testing_light_mode"
        case uiTestingDarkMode = "ui_testing_dark_mode"
        case previewCoredata = "preview_core_data"

        /// If the argument is enabled or not.
        public var enabled: Bool {
            CommandLine.arguments.contains(rawValue)
        }
    }

    /// Environment variables driven by the current schemes configuration.
    public enum EnvironmentVariables: String {
        case startingStackScreen = "starting_stack_screen"

        public var value: String? {
            ProcessInfo.processInfo.environment[rawValue]
        }
    }
}
