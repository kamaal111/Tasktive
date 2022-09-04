//
//  SettingsScreens.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import Foundation

public enum SettingsScreens: Hashable, Codable, CaseIterable {
    public static let allCases: [SettingsScreens] = [
        .feedback(style: .feature),
        .feedback(style: .bug),
        .feedback(style: .other),
        .appColor,
        .supportAuthor,
    ]

    case feedback(style: FeedbackStyles)
    case appColor
    case supportAuthor

    public var title: String {
        switch self {
        case let .feedback(style):
            return style.title
        case .appColor:
            return NSLocalizedString("App colors", bundle: .module, comment: "")
        case .supportAuthor:
            return NSLocalizedString("Support Author", bundle: .module, comment: "")
        }
    }
}

public enum FeedbackStyles: Hashable, Codable, Identifiable, CaseIterable {
    case feature
    case bug
    case other

    public var id: String {
        title
    }

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
