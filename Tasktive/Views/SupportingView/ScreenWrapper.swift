//
//  ScreenWrapper.swift
//  Tasktive
//
//  Created by Kamaal Farah on 24/07/2022.
//

import SwiftUI
import SalmonUI

struct ScreenWrapper<Content: View>: View {
    @EnvironmentObject private var namiNavigator: NamiNavigator

    @StateObject private var stackNavigator: StackNavigator

    let screen: NamiNavigator.Screens
    let content: Content

    init(screen: NamiNavigator.Screens, @ViewBuilder content: () -> Content) {
        self.screen = screen
        self.content = content()
        self._stackNavigator = StateObject(wrappedValue: StackNavigator(screen: screen))
    }

    var body: some View {
        NavigationStack(path: $stackNavigator.path) {
            content
                .navigationTitle(Text(screen.title))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
            #endif
            #if DEBUG
                .navigationDestination(for: StackNavigator.Screens.self) { screen in
                    KJustStack(content: {
                        switch screen {
                        case .playground:
                            PlaygroundScreen()
                        case .appLogoCreator:
                            AppLogoCreator()
                        }
                    })
                    .navigationTitle(Text(screen.title))
                    #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                    #endif
                }
            #endif
                .environmentObject(stackNavigator)
        }
        .onChange(of: namiNavigator.currentSelection, perform: { newValue in
            Task {
                await stackNavigator.changeScreen(to: newValue)
            }
        })
    }
}

struct ScreenWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ScreenWrapper(screen: .tasks, content: {
            Text("Hello")
        })
    }
}
