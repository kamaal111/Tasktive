//
//  DeviceModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 16/07/2022.
//

import SwiftUI
import Network
import Logster
import Foundation
import Environment

private let logger = Logster(from: DeviceModel.self)

final class DeviceModel: ObservableObject {
    @Published private var deviceOrientation: DeviceOrientation?
    @Published private(set) var isConnectedToNetwork = true {
        didSet { isConnectedToNetworkDidSet() }
    }

    private let networkMonitor = NWPathMonitor()

    #if canImport(UIKit)
    private let notifications: [Notification.Name] = [
        UIDevice.orientationDidChangeNotification,
    ]
    #else
    private let notifications: [Notification.Name] = []
    #endif

    init() {
        #if canImport(UIKit)
        setOrientation(from: UIDevice.current)
        #endif

        setupNotifications()

        if Environment.Features.iCloudSyncing {
            networkMonitor.pathUpdateHandler = networkMonitorTask
            networkMonitor.start(queue: .monitor)
        }
    }

    deinit {
        removeNotifications()
    }

    static let deviceType: DeviceType = .current

    private func networkMonitorTask(_ path: NWPath) {
        Task {
            await setIsConnectedToNetwork(path.status == .satisfied)
        }
    }

    @MainActor
    private func setIsConnectedToNetwork(_ state: Bool) {
        guard isConnectedToNetwork != state else { return }

        withAnimation {
            isConnectedToNetwork = state
        }
    }

    private func isConnectedToNetworkDidSet() {
        logger.info("connected to network: \(isConnectedToNetwork)")
    }

    private func setupNotifications() {
        notifications.forEach { notification in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNotification),
                name: notification,
                object: .none
            )
        }
    }

    private func removeNotifications() {
        notifications.forEach { notification in
            NotificationCenter.default.removeObserver(self, name: notification, object: .none)
        }
    }

    @objc
    private func handleNotification(_ notification: Notification) {
        switch notification.name {
        #if canImport(UIKit)
        case UIDevice.orientationDidChangeNotification:
            guard let device = notification.object as? UIDevice else { return }
            setOrientation(from: device)
        #endif
        default:
            break
        }
    }

    #if canImport(UIKit)
    private func setOrientation(from device: UIDevice) {
        var newDeviceOrientation: DeviceOrientation?

        switch device.orientation {
        case .portrait:
            newDeviceOrientation = .portrait
        case .landscapeLeft, .landscapeRight:
            newDeviceOrientation = .landscape
        case .faceUp, .faceDown:
            newDeviceOrientation = .portrait
        case .portraitUpsideDown:
            newDeviceOrientation = deviceOrientation ?? .portrait
        case .unknown:
            break
        @unknown default:
            break
        }

        guard newDeviceOrientation != nil, deviceOrientation != newDeviceOrientation else { return }

        deviceOrientation = newDeviceOrientation
    }
    #endif
}

enum DeviceOrientation {
    case portrait
    case landscape
    case flat
}

enum DeviceType: String {
    case iPhone
    case iPad
    case mac

    var shouldHaveSidebar: Bool {
        self != .iPhone
    }

    var issueLabel: String {
        rawValue
    }

    fileprivate static let current: DeviceType = {
        #if canImport(UIKit)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .iPad
        }
        return .iPhone
        #else
        return .mac
        #endif
    }()
}
