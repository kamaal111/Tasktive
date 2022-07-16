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

    var body: some View {
        KJustStack {
            if DeviceModel.deviceType == .iPhone {
                TabView(selection: .constant(0)) {
                    NavigationStack {
                        DetailsColumn()
                    }
                    .tabItem {
                        Image(systemName: "doc.text.image")
                        Text("Today or whatever day")
                    }
                    .tag(0)
                }
            } else {
                NavigationSplitView(sidebar: {
                    Sidebar()
                }) {
                    NavigationStack {
                        DetailsColumn()
                    }
                }
            }
        }
        .environmentObject(deviceModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
