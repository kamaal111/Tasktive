//
//  ScreenWrapper.swift
//  Tasktive
//
//  Created by Kamaal Farah on 24/07/2022.
//

import SwiftUI

private let logger = Logster(label: "ScreenWrapper")

struct ScreenWrapper<Content: View>: View {
    @State private var path = NavigationPath()

    let screen: NamiNavigator.Screens
    let content: Content

    init(screen: NamiNavigator.Screens, @ViewBuilder content: () -> Content) {
        self.screen = screen
        self.content = content()
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle(Text(screen.title))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .onChange(of: path) { newValue in
            logger.info("current path is \(newValue) for \(screen)")
        }
    }
}

struct ScreenWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ScreenWrapper(screen: .tasks, content: {
            Text("Hello")
        })
    }
}
