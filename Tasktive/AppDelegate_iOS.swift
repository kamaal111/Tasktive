//
//  AppDelegate_iOS.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if os(iOS)
import UIKit
import CloudKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()

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
        fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            NotificationCenter.default.post(name: .iCloudChanges, object: notification)
        }
    }
}
#endif
