//
//  AppDelegate_macOS.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if os(macOS)
import Cocoa
import Skypiea
import Logster
import CloudKit
import Environment

private let logger = Logster(from: AppDelegate.self)

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let skypiea: Skypiea = .shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let application = notification.object as? NSApplication else { return }
        application.registerForRemoteNotifications()

        if Environment.Features.iCloudSyncing {
            Task {
                do {
                    try await skypiea.subscripeToAll()
                } catch {
                    logger.error(label: "failed to subscribe to iCloud subscriptions", error: error)
                }
            }
        }
    }

    func application(_: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            NotificationCenter.default.post(name: .iCloudChanges, object: notification)
        }
    }
}
#endif
