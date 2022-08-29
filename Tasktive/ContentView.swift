//
//  ContentView.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import SwiftUI
import PopperUp

struct ContentView: View {
    @StateObject private var deviceModel = DeviceModel()
    @StateObject private var namiNavigator = NamiNavigator()
    @StateObject private var popperUpManager = PopperUpManager(config: .init())

    init() { }

    var body: some View {
        MainView()
            .onChange(of: namiNavigator.currentSelection, perform: { newValue in
                NotificationCenter.default.post(name: .currentScreenChanged, object: newValue)
            })
            .environmentObject(deviceModel)
            .environmentObject(namiNavigator)
            .withPopperUp(popperUpManager)
        #if os(macOS)
            .frame(minWidth: Constants.UI.mainViewMinimumSize.width, minHeight: Constants.UI.mainViewMinimumSize.height)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TasksViewModel(preview: true))
    }
}
