//
//  SettingsScreens.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import Foundation
import TasktiveLocale

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
    case logs

    public var title: String {
        switch self {
        case let .feedback(style):
            return style.title
        case .appColor:
            return TasktiveLocale.getText(.APP_COLORS)
        case .supportAuthor:
            return TasktiveLocale.getText(.SUPPORT_AUTHOR)
        case .logs:
            return TasktiveLocale.getText(.LOGS)
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
            return TasktiveLocale.getText(.FEATURE_REQUEST)
        case .bug:
            return TasktiveLocale.getText(.REPORT_BUG)
        case .other:
            return TasktiveLocale.getText(.OTHER_FEEDBACK)
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
