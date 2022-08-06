//
//  MainView.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//

import SwiftUI
import SalmonUI

struct MainView: View {
    @EnvironmentObject private var deviceModel: DeviceModel
    @EnvironmentObject private var namiNavigator: NamiNavigator

    init() { }

    var body: some View {
        KJustStack {
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .previewEnvironment()
    }
}
