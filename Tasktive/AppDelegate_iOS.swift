//
//  AppDelegate_iOS.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if os(iOS)
import UIKit
import Logster
import CloudKit
import Environment

private let logger = Logster(from: AppDelegate.self)

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let backend = Backend(preview: false)

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()

        if Environment.Features.iCloudSyncing {
            Task {
                do {
                    try await backend.notifications.subscribeToAll()
                } catch {
                    logger.error(label: "failed to subscribe to iCloud subscriptions", error: error)
                }
            }
        }

        return true
    }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    func application(
        _: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            NotificationCenter.default.post(name: .iCloudChanges, object: notification)
            completionHandler(.newData)
        }
    }
}
#endif
