//
//  UserData.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 16/09/2022.
//

import Logster
import Foundation

private let logger = Logster(from: UserData.self)

final class UserData: ObservableObject {
    @Published var iCloudSyncingIsEnabled: Bool {
        didSet {
            iCloudSyncingIsEnabledDidSet()
        }
    }

    @Published private(set) var notificationsAreAuthorized = false {
        didSet {
            logger.info("notifications are authorized; \(notificationsAreAuthorized)")
        }
    }

    private let backend: Backend
    private let notifications: [Notification.Name] = [
        .appBecameActive,
    ]

    init(preview: Bool = false) {
        self.iCloudSyncingIsEnabled = UserDefaults.iCloudSyncingIsEnabled ?? true

        let backend = Backend(preview: preview)
        self.backend = backend

        Task { await requestNotificationAuthorizationIfRequestBefore() }
        setupObservers()
    }

    deinit {
        removeObservers()
    }

    func authorizeNotifications() async {
        let isAuthorized: Bool
        do {
            isAuthorized = try await backend.notifications.authorize()
        } catch {
            logger.error(label: "failed to authorize the user", error: error)
            return
        }

        logger.info(
            "successfully requested if user is authorized to recieve user notifications",
            "isAuthorized='\(isAuthorized)'"
        )

        if !notificationsHaveBeenRequestedBefore {
            notificationsHaveBeenRequestedBefore = true
        }

        await setNotificationsAreAuthorized(isAuthorized)
    }

    private var notificationsHaveBeenRequestedBefore: Bool {
        get {
            UserDefaults.notificationsHaveBeenRequestedBefore ?? false
        }
        set {
            UserDefaults.notificationsHaveBeenRequestedBefore = newValue
        }
    }

    private func requestNotificationAuthorizationIfRequestBefore() async {
        if notificationsHaveBeenRequestedBefore {
            await authorizeNotifications()
        }
    }

    private func setupObservers() {
        notifications.forEach { notification in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNotification),
                name: notification,
                object: .none
            )
        }
    }

    private func removeObservers() {
        notifications.forEach { notification in
            NotificationCenter.default.removeObserver(self, name: notification, object: .none)
        }
    }

    @objc
    private func handleNotification(_ notification: Notification) {
        switch notification.name {
        case .appBecameActive:
            Task { await requestNotificationAuthorizationIfRequestBefore() }
        default:
            break
        }
    }

    @MainActor
    private func setNotificationsAreAuthorized(_ isAuthorized: Bool) {
        guard isAuthorized != notificationsAreAuthorized else { return }

        notificationsAreAuthorized = isAuthorized
    }

    private func iCloudSyncingIsEnabledDidSet() {
        UserDefaults.iCloudSyncingIsEnabled = iCloudSyncingIsEnabled
    }
}
