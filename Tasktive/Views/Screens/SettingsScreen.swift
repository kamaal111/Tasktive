//
//  SettingsScreen.swift
//  Tasktive
//
//  Created by Kamaal Farah on 24/07/2022.
//

import SwiftUI

private let SCREEN: NamiNavigator.Screens = .settings

struct SettingsScreen: View {
    var body: some View {
        ScreenWrapper(screen: SCREEN) {
            Text("Settings")
        }
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
