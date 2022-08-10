//
//  Theme.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 10/08/2022.
//

import SwiftUI
import SettingsUI

final class Theme: ObservableObject {
    @Environment(\.colorScheme) private var colorScheme

    @Published private(set) var appColor: AppColor?

    init(appColor: AppColor? = nil) {
        self.appColor = appColor
    }

    var currentAccentColor: Color {
        guard let varients = appColor?.variants else { return Color("AccentColor") }

        if colorScheme == .dark {
            return varients.dark.color
        }

        return varients.light.color
    }
}
