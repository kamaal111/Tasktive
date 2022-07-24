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
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScreenWrapper(screen: SCREEN) {
            Form {
                // - TODO: LOCALIZE THIS
                Section(header: Text("About")) {
                    SettingsUI.VersionRowView()
                }
            }
            // - TODO: LOCALIZE THIS
            Text("Made by Kamaal")
                .foregroundColor(.secondary)
                .ktakeSizeEagerly(alignment: .bottom)
        }
    }
}

extension SettingsScreen {
    final class ViewModel: ObservableObject {
        var versionText: String? {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        }

        var buildNumber: String? {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        }
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        var configuration = PreviewConfiguration()
        configuration.screen = .settings

        return ForEach(ColorScheme.allCases, id: \.self) { scheme in
            MainView()
                .previewEnvironment(withConfiguration: configuration)
                .colorScheme(scheme)
        }
    }
}
