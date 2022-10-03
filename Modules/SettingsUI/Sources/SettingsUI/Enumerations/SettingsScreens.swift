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
        .feedback(style: .feature, predefinedDescription: nil),
        .feedback(style: .bug, predefinedDescription: nil),
        .feedback(style: .other, predefinedDescription: nil),
        .appColor,
        .supportAuthor,
    ]

    case feedback(style: FeedbackStyles, predefinedDescription: String?)
    case appColor
    case supportAuthor
    case logs
    case acknowledgements

    public var title: String {
        switch self {
        case let .feedback(style, _):
            return style.title
        case .appColor:
            return TasktiveLocale.getText(.APP_COLORS)
        case .supportAuthor:
            return TasktiveLocale.getText(.SUPPORT_AUTHOR)
        case .logs:
            return TasktiveLocale.getText(.LOGS)
        case .acknowledgements:
            return TasktiveLocale.getText(.ACKNOWLEDGEMENTS)
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
