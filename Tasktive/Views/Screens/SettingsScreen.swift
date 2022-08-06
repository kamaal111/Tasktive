//
//  SettingsScreen.swift
//  Tasktive
//
//  Created by Kamaal Farah on 24/07/2022.
//

import SwiftUI
import SalmonUI
import SettingsUI

private let SCREEN: NamiNavigator.Screens = .settings

struct SettingsScreen: View {
    @EnvironmentObject private var namiNavigator: NamiNavigator

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScreenWrapper(screen: SCREEN) {
            Form {
                SettingsUI.FeedbackSection()
                SettingsUI.AboutSection()
            }
        }
        #if os(macOS)
        .padding(.vertical, .medium)
        .padding(.horizontal, .medium)
        .ktakeSizeEagerly(alignment: .topLeading)
        #endif
    }
}

extension SettingsScreen {
    final class ViewModel: ObservableObject { }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        var configuration = PreviewConfiguration()
        configuration.screen = SCREEN

        return ForEach(ColorScheme.allCases, id: \.self) { scheme in
            MainView()
                .previewEnvironment(withConfiguration: configuration)
                .colorScheme(scheme)
        }
    }
}
