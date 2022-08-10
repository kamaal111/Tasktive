//
//  AppColorAccent.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 10/08/2022.
//

import SwiftUI
import SettingsUI

struct AppColorAccentWrapper<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var appColorAccent: AppColorAccent

    let content: Content

    init(appColorAccent: Binding<AppColorAccent>, @ViewBuilder content: () -> Content) {
        self._appColorAccent = appColorAccent
        self.content = content()
    }

    var body: some View {
        content
            .accentColor(appColorAccent.currentAccentColor)
            .environment(\.appColorAccent, appColorAccent)
    }
}

struct AppColorAccent {
    @Environment(\.colorScheme) private var colorScheme

    let appColor: AppColor?

    var currentAccentColor: Color {
        guard let varients = appColor?.variants else { return Color("AccentColor") }

        if colorScheme == .dark {
            return varients.dark.color
        }

        return varients.light.color
    }
}

struct AppColorAccentKey: EnvironmentKey {
    static var defaultValue = AppColorAccent(appColor: nil)
}

extension EnvironmentValues {
    var appColorAccent: AppColorAccent {
        get { self[AppColorAccentKey.self] }
        set { self[AppColorAccentKey.self] = newValue }
    }
}
