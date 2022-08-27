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

    #if swift(>=5.7)
    init(destination: Destination, @ViewBuilder content: () -> Content) {
        self.destination = destination
        self.content = content()
        self.onNavigate = { _ in }
    }
    #else
    init(
        onNavigate: @escaping (_ destination: Destination) -> Void,
        destination: Destination,
        @ViewBuilder content: () -> Content
    ) {
        self.destination = destination
        self.content = content()
        self.onNavigate = onNavigate
    }
    #endif

    var body: some View {
        KJustStack {
            #if swift(>=5.7)
            if #available(macOS 13.0, iOS 16, *) {
                NavigationLink(value: destination) {
                    view
                }
            } else {
                fallbackView
            }
            #else
            fallbackView
            #endif
        }
        .buttonStyle(.plain)
    }

    private var fallbackView: some View {
        Button(action: { onNavigate(destination) }) {
            content
        }
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

#if DEBUG && swift(>=5.7)
@available(macOS 13.0, iOS 16, *)
struct WideNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        WideNavigationLink(destination: StackNavigator.Screens.playground, content: {
            Text("Hello")
        })
    }
}
#endif
