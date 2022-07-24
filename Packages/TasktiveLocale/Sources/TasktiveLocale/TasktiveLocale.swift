//
//  TasktiveLocale.swift
//
//
//  Created by Kamaal M Farah on 16/07/2022.
//

import Foundation

/// Main Localization util struct.
public struct TasktiveLocale {
    private init() { }

    /// Depending on the key returns a localized string
    /// - Parameter key: the key to get the localized string
    /// - Returns: a localized string
    public static func getText(_ key: Keys) -> String {
        key.localized
    }
}

extension TasktiveLocale.Keys {
    /// Localize ``CSLocale/CSLocale/Keys``.
    public var localized: String {
        localized(with: [])
    }

    /// Localize ``CSLocale/CSLocale/Keys`` with a injected variable.
    /// - Parameter variables: variable to inject in to string.
    /// - Returns: Returns a localized string.
    public func localized(with variables: [CVarArg]) -> String {
        let bundle = Bundle.module
        switch variables {
        case _ where variables.isEmpty:
            return NSLocalizedString(rawValue, bundle: bundle, comment: "")
        case _ where variables.count == 1:
            return String(format: NSLocalizedString(rawValue, bundle: bundle, comment: ""), variables[0])
        default:
            #if DEBUG
            fatalError("Amount of variables is not supported")
            #else
            return NSLocalizedString(rawValue, bundle: bundle, comment: "")
            #endif
        }
    }
}
