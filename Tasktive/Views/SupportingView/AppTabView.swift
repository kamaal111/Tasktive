//
//  AppTabView.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import ShrimpExtensions

struct AppTabView: View {
    @EnvironmentObject private var namiNavigator: NamiNavigator

    init() { }

    var body: some View {
        TabView(selection: $namiNavigator.tabSelection) {
            ForEach(namiNavigator.tabs, id: \.self) { screen in
                DetailsColumn()
                    .tabItem {
                        Image(systemName: screen.icon)
                        Text(screen.title)
                    }
                    .tag(screen.tag)
            }
        }
        /// The prevents the tab view to crash when changing betweens screens with a Form.
        /// Con is that the current detail screen will make a full refresh on every appear 🥲
        .id(namiNavigator.currentSelection)
    }
}

#if DEBUG
struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
            .previewEnvironment()
    }
}
#endif
