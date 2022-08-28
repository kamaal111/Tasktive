//
//  WideNavigationLink.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/08/2022.
//

import SwiftUI
import SalmonUI

struct WideNavigationLink<Destination: Codable & Hashable, Content: View>: View {
    let destination: Destination
    let content: Content
    let onNavigate: (_ destination: Destination) -> Void

    init(destination: Destination, @ViewBuilder content: () -> Content) {
        self.destination = destination
        self.content = content()
        self.onNavigate = { _ in }
    }

    var body: some View {
        KJustStack {
            NavigationLink(value: destination) {
                view
            }
        }
        .buttonStyle(.plain)
    }

    private var view: some View {
        content
            .foregroundColor(.accentColor)
        #if os(macOS)
            // Hack: need the following 2 lines to be fully clickable on macOS
            .ktakeWidthEagerly()
            .background(Color(nsColor: .separatorColor).opacity(0.01))
        #endif
    }
}

#if DEBUG
struct WideNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        WideNavigationLink(destination: StackNavigator.Screens.playground, content: {
            Text("Hello")
        })
    }
}
#endif
