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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
