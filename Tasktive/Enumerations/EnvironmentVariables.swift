//
//  EnvironmentVariables.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/09/2022.
//

import Foundation

enum EnvironmentVariables: String {
    case startingStackScreen = "starting_stack_screen"

    var value: String? {
        ProcessInfo.processInfo.environment[rawValue]
    }
}
