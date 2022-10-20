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
import UserNotifications

private let logger = Logster(from: AppDelegate.self)

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let userNotificationCenter: UNUserNotificationCenter = .current()
    private let backend: Backend = .shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()
        userNotificationCenter.delegate = self

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

    // - MARK: UIApplicationDelegate

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

    // - MARK: UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleUserNotification(response.notification, mode: .background)
        completionHandler()
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleUserNotification(notification, mode: .foreground)
        completionHandler(UNNotificationPresentationOptions(rawValue: 0))
    }

    private func handleUserNotification(_ notification: UNNotification, mode: UserNotificationMode) {
        print("reading notification from \(mode)")
        let content = notification.request.content
        let userInfo = content.userInfo as? [String: String]
        print("userInfo", userInfo as Any)
        print("id", notification.request.identifier)
    }

    private enum UserNotificationMode {
        case foreground
        case background
    }
}
#endif
