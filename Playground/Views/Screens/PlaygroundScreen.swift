//
//  PlaygroundScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if DEBUG
import SwiftUI
import SalmonUI

private let SCREEN: StackNavigator.Screens = .playground

struct PlaygroundScreen: View {
    var body: some View {
        KScrollableForm {
            KSection(header: "Personalization") {
                WideNavigationLink(destination: StackNavigator.Screens.appLogoCreator) {
                    HStack {
                        Text("App logo creator")
                        Spacer()
                        #if os(macOS)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                        #endif
                    }
                    .ktakeWidthEagerly()
                }
            }
        }
        #if os(macOS)
        .padding(.vertical, .medium)
        .padding(.horizontal, .medium)
        #endif
    }
}

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
