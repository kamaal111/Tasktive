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
    @EnvironmentObject private var stackNavigator: StackNavigator

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        Form {
            SettingsUI.FeedbackSection(onFeedbackPress: { style in
                stackNavigator.navigate(to: style)
            })
            SettingsUI.AboutSection()
        }
        .navigationDestination(for: FeedbackStyles.self) { style in
            SettingsUI.FeedbackScreen(style: style)
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
