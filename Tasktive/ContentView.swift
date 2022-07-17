//
//  ContentView.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import SwiftUI
import SalmonUI

struct ContentView: View {
    @StateObject private var deviceModel = DeviceModel()
    @StateObject private var namiNavigator = NamiNavigator()

    init() { }

    var body: some View {
        KJustStack {
            if DeviceModel.deviceType.shouldHaveSidebar {
                NavigationSplitView(sidebar: {
                    Sidebar()
                }) {
                    NavigationStack(path: namiNavigator.screenPath(namiNavigator.sidebarSelection)) {
                        DetailsColumn()
                    }
                }
            } else {
                AppTabView()
            }
        }
        .environmentObject(deviceModel)
        .environmentObject(namiNavigator)
        #if os(macOS)
            .frame(minWidth: Constants.UI.mainViewMinimumSize.width, minHeight: Constants.UI.mainViewMinimumSize.height)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.context)
            .environmentObject(TasksViewModel(preview: true))
    }
}
