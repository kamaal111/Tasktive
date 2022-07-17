//
//  Sidebar.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI

struct Sidebar: View {
    @EnvironmentObject private var namiNavigator: NamiNavigator

    var body: some View {
        ForEach(namiNavigator.sidebarButtons, id: \.self) { screen in
            Button(action: { namiNavigator.navigate(to: screen) }) {
                Label(screen.title, systemImage: screen.icon)
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
            .previewEnvironment()
    }
}
#endif
