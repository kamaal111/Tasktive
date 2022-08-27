//
//  PlaygroundScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if DEBUG && swift(>=5.7)
import SwiftUI
import SalmonUI

@available(macOS 13.0, *)
private let SCREEN: StackNavigator.Screens = .playground

@available(macOS 13.0, *)
struct PlaygroundScreen: View {
    var body: some View {
        KScrollableForm {
            KSection(header: "Personalization") {
                PlaygroundNavigationButton(title: "App logo creator", destination: .appLogoCreator)
            }
            KSection(header: "Data") {
                PlaygroundNavigationButton(title: "Core Data viewer", destination: .coreDataViewer)
                #if os(macOS)
                    .padding(.bottom, .extraSmall)
                #endif
                PlaygroundNavigationButton(title: "Cloud Kit data viewer", destination: .cloudKitDataViewer)
            }
        }
        #if os(macOS)
        .padding(.vertical, .medium)
        .padding(.horizontal, .medium)
        #endif
    }
}

@available(macOS 13.0, *)
struct PlaygroundScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PlaygroundScreen()
                .navigationTitle(Text(SCREEN.title))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
#endif
