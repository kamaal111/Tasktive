//
//  Sidebar.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import SalmonUI

struct Sidebar: View {
    @EnvironmentObject private var namiNavigator: NamiNavigator

    var body: some View {
        List {
            Section(header: Text(localized: .SCENES)) {
                ForEach(namiNavigator.sidebarButtons, id: \.self) { screen in
                    VStack(alignment: .leading) {
                        Button(action: { namiNavigator.navigate(to: screen) }) {
                            Label(screen.title, systemImage: screen.icon)
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationSplitView(sidebar: { Sidebar() }) {
            Text("Details")
        }
        .padding(.vertical, .medium)
        .previewEnvironment()
    }
}
#endif
