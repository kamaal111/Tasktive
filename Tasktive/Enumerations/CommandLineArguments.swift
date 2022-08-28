//
//  CommandLineArguments.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 29/08/2022.
//

import Foundation

enum CommandLineArguments: String {
    case uiTestingLightMode = "ui_testing_light_mode"
    case uiTestingDarkMode = "ui_testing_dark_mode"
    case previewCoredata = "preview_core_data"

    var enabled: Bool {
        CommandLine.arguments.contains(rawValue)
    }
}
