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
        if #available(macOS 13.0, iOS 16, *) {
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
        } else {
            // - TODO: OLDER NAVIGATION BUTTON
            Text("Panic alright")
        }
    }
}

#if DEBUG
@available(macOS 13.0, iOS 16, *)
struct WideNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        WideNavigationLink(destination: StackNavigator.Screens.playground, content: {
            Text("Hello")
        })
    }
}
#endif
