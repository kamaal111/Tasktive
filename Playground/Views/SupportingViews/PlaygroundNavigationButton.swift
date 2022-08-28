//
//  PlaygroundNavigationButton.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

#if DEBUG
import SwiftUI
import SalmonUI

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

struct PlaygroundNavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundNavigationButton(title: "Yes", destination: .coreDataViewer)
    }
}
#endif
