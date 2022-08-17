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

    init(destination: Destination, @ViewBuilder content: () -> Content) {
        self.destination = destination
        self.content = content()
    }

    var body: some View {
        NavigationLink(value: destination) {
            content
                .foregroundColor(.accentColor)
            #if os(macOS)
                // Hack: need the following 2 lines to be fully clickable on macOS
                .ktakeWidthEagerly()
                .background(Color(nsColor: .separatorColor).opacity(0.01))
            #endif
        }
        .buttonStyle(.plain)
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
