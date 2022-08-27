//
//  DetailsColumn.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import SalmonUI

struct DetailsColumn: View {
    @EnvironmentObject private var namiNavigator: NamiNavigator

    var body: some View {
        if #available(macOS 13.0, iOS 16, *) {
            ScreenWrapper(screen: namiNavigator.currentSelection) {
                switch namiNavigator.currentSelection {
                case .tasks:
                    TasksScreen()
                case .settings:
                    SettingsScreen()
                }
            }
        } else {
            // - TODO: OLDER COLUMN VIEW
            Text("Yes panic more")
        }
    }
}

#if DEBUG
struct DetailsColumn_Previews: PreviewProvider {
    static var previews: some View {
        DetailsColumn()
            .previewEnvironment()
    }
}
#endif
