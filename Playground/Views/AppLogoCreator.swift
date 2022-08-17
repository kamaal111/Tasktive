//
//  AppLogoCreator.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/08/2022.
//

#if DEBUG
import SwiftUI

private let SCREEN: StackNavigator.Screens = .appLogoCreator

struct AppLogoCreator: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct AppLogoCreator_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppLogoCreator()
                .navigationTitle(Text(SCREEN.title))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
#endif
