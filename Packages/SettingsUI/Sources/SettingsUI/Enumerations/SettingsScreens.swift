//
//  SettingsScreens.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import Foundation

public enum SettingsScreens: Hashable, Codable {
    case feedback(style: FeedbackStyles)
    case appColor
}

public enum FeedbackStyles: Hashable, Codable, CaseIterable {
    case feature
    case bug
    case other

    public var title: String {
        switch self {
        case .feature:
            return NSLocalizedString("Feature request", bundle: .module, comment: "")
        case .bug:
            return NSLocalizedString("Report bug", bundle: .module, comment: "")
        case .other:
            return NSLocalizedString("Other feedback", bundle: .module, comment: "")
        }
    }

    public var imageSystemName: String {
        switch self {
        case .feature: return "paperplane"
        case .bug: return "ant"
        case .other: return "newspaper"
        }
    }

    public var labels: [String] {
        let labels: [String]
        switch self {
        case .feature: labels = ["enhancement"]
        case .bug: labels = ["bug"]
        case .other: labels = []
        }
        return labels + ["in app feedback"]
    }
}
