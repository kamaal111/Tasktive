//
//  PlaygroundScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if DEBUG
import SwiftUI
import SalmonUI
import Environment
import SharedModels

private let SCREEN: StackNavigator.Screens = .playground

struct PlaygroundScreen: View {
    @EnvironmentObject
    private var userData: UserData

    var body: some View {
        KScrollableForm {
            KSection(header: "Personalization") {
                PlaygroundNavigationButton(title: "App logo creator", destination: .appLogoCreator)
            }
            KSection(header: "Data") {
                PlaygroundNavigationButton(title: "Core Data viewer", destination: .coreDataViewer)
                #if os(macOS)
                    .padding(.bottom, .extraSmall)
                #endif
                if Environment.Features.iCloudSyncing {
                    PlaygroundNavigationButton(title: "Cloud Kit data viewer", destination: .cloudKitDataViewer)
                }
            }
            KSection(header: "Testing") {
                Button(action: testNotification) {
                    Text(userData.notificationsAreAuthorized
                        ? "Notifications are authorized"
                        : "Notifications are not authorized")
                }
            }
        }
        #if os(macOS)
        .padding(.vertical, .medium)
        .padding(.horizontal, .medium)
        #endif
    }

    private func testNotification() {
        Task {
            if !userData.notificationsAreAuthorized {
                await userData.authorizeNotifications()
                return
            }

            let whenToNotify = Date().addingTimeInterval(5)
            let content = NotificationContent(
                title: "Testing",
                subTitle: "The test of tests",
                category: .playground,
                sound: .default,
                data: ["yes": "no"]
            )
            let id = UUID()
            Backend.shared.notifications.schedule(content, for: whenToNotify, identifier: id)
//            Backend.shared.notifications.cancel(identifier: id)
        }
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
