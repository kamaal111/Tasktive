//
//  PlaygroundScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if DEBUG
import SwiftUI
import SalmonUI

struct PlaygroundScreen: View {
    var body: some View {
        KScrollableForm {
            VStack {
                KSection(header: "Personalization") {
                    WideNavigationLink(destination: StackNavigator.Screens.appLogoCreator) {
                        HStack {
                            Text("App logo creator")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .ktakeWidthEagerly()
                    }
                }
            }
            .padding(.vertical, .medium)
            .padding(.horizontal, .medium)
        }
    }
}

struct PlaygroundScreen_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundScreen()
    }
}
#endif
