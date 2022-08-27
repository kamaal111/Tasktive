//
//  PlaygroundNavigationButton.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

#if DEBUG && swift(>=5.7)
import SwiftUI
import SalmonUI

@available(macOS 13.0, *)
struct PlaygroundNavigationButton: View {
    let title: String
    let destination: StackNavigator.Screens

    init(title: String, destination: StackNavigator.Screens) {
        self.title = title
        self.destination = destination
    }

    var body: some View {
        WideNavigationLink(destination: destination) {
            HStack {
                Text(title)
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

@available(macOS 13.0, *)
struct PlaygroundNavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundNavigationButton(title: "Yes", destination: .coreDataViewer)
    }
}
#endif
