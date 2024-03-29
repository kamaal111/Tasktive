//
//  MainView.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var deviceModel: DeviceModel
    @EnvironmentObject private var namiNavigator: NamiNavigator
    @EnvironmentObject private var theme: Theme

    init() { }

    var body: some View {
        SplashScreenStack(enabled: DeviceModel.deviceType != .mac) {
            EditModeStack {
                if DeviceModel.deviceType.shouldHaveSidebar {
                    #if os(iOS) // if iPad
                    NavigationSplitView(sidebar: { Sidebar() }, detail: { DetailsColumn() })
                    #else // if mac
                    // Can't use `NavigationSplitView` yet because the sidebar breaks the navigation on macOS
                    NavigationView {
                        Sidebar()
                        DetailsColumn()
                    }
                    #endif
                } else {
                    AppTabView() // if iPhone
                }
            }
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .previewEnvironment()
    }
}
#endif
