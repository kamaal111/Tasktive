//
//  View+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import SalmonUI
#if DEBUG
import PopperUp
#endif

extension View {
    func padding(_ edges: Edge.Set = .all, _ length: AppSizes) -> some View {
        padding(edges, length.rawValue)
    }

    func cornerRadius(_ length: AppSizes) -> some View {
        cornerRadius(length.rawValue)
    }

    func withNavigation(navigator: NamiNavigator) -> some View {
        KJustStack {
            #if os(iOS)
            self
            #else
            if let view = navigator.currentStackScreen {
                KJustStack {
                    switch view {
                    case .feedback:
                        Text("Feedback")
                    }
                }
                .environmentObject(navigator)
            } else {
                self
            }
            #endif
        }
    }

    #if DEBUG
    func previewEnvironment(withConfiguration configuration: PreviewConfiguration? = nil) -> some View {
        let namiNavigator = NamiNavigator()

        if let configuration = configuration {
            if let screen = configuration.screen {
                namiNavigator.tabSelection = screen
                namiNavigator.sidebarSelection = screen
            }
        }

        return environment(\.managedObjectContext, PersistenceController.preview.context)
            .environmentObject(DeviceModel())
            .environmentObject(namiNavigator)
            .environmentObject(TasksViewModel(preview: true))
            .withPopperUp(PopperUpManager(config: .init()))
    }
    #endif
}

#if DEBUG
struct PreviewConfiguration {
    var screen: NamiNavigator.Screens?

    init() { }
}
#endif
