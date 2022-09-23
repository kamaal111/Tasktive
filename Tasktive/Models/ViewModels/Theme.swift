//
//  Theme.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 10/08/2022.
//

import SwiftUI
import SettingsUI

final class Theme: ObservableObject {
    @Published private(set) var appColor: AppColor?

    init() {
        self.appColor = UserDefaults.appColor
    }

    func currentAccentColor(scheme: ColorScheme) -> Color {
        guard let varients = appColor?.variants else { return .AccentColor }

        if scheme == .dark {
            return varients.dark.color
        }

        return varients.light.color
    }

    @MainActor
    func setAppColor(_ color: AppColor) {
        appColor = color
        UserDefaults.appColor = color
    }
}
