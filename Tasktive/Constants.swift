//
//  Constants.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import Foundation
import CoreGraphics
import ShrimpExtensions

enum Constants {
    static let gitHubUsername = "kamaal111"
    static let repoName = "Tasktive"
    static let bundleIdentifier = Bundle.main.bundleIdentifier!
    static let appGroupIdentifier = "group.DXUKH9VF73.io.kamaal.Tasktive"
    static let appAccentColorKey = "AccentColor"

    enum UI {
        static let mainViewMinimumSize: CGSize = .squared(300)
        static let mainViewHorizontalWidth: CGFloat = AppSizes.medium.rawValue
        static let settingsViewMinimumSize = CGSize(width: 250, height: 300)
    }
}
