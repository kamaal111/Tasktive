//
//  Sidebar.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale

struct Sidebar: View {
    @EnvironmentObject private var namiNavigator: NamiNavigator
    @EnvironmentObject private var theme: Theme

    var body: some View {
        List {
            Section(header: Text(localized: .SCENES)) {
                ForEach(namiNavigator.sidebarButtons, id: \.self) { screen in
                    VStack(alignment: .leading) {
                        Button(action: { Task { await namiNavigator.navigate(to: screen) } }) {
                            Label(screen.title, systemImage: screen.icon)
                                .accentColor(theme.currentAccentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        #if os(macOS)
        .toolbar(content: {
            Button(action: toggleSidebar) {
                Label(TasktiveLocale.getText(.TOGGLE_SIDEBAR), systemImage: "sidebar.left")
                    .foregroundColor(.accentColor)
            }
            .accentColor(theme.currentAccentColor)
        })
        #endif
    }

    #if os(macOS)
    private func toggleSidebar() {
        guard let firstResponder = NSApp.keyWindow?.firstResponder else { return }
        firstResponder.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    #endif
}

#if DEBUG && swift(>=5.7)
@available(macOS 13.0, iOS 16, *)
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
