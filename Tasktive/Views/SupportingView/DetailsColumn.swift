//
//  DetailsColumn.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI

struct DetailsColumn: View {
    @EnvironmentObject private var namiNavigator: NamiNavigator

    var body: some View {
        switch currentSelection {
        case .tasks, .none:
            TasksScreen()
        case .settings:
            SettingsScreen()
        }
    }

    private var currentSelection: NamiNavigator.Screens? {
        if DeviceModel.deviceType.shouldHaveSidebar {
            return namiNavigator.sidebarSelection
        }
        return namiNavigator.tabSelection
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
