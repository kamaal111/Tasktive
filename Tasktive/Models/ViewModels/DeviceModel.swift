//
//  DeviceModel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 16/07/2022.
//

import Foundation
import SwiftUI

final class DeviceModel: ObservableObject {
    @Published private(set) var deviceOrientation: DeviceOrientation?

    init() {
        #if canImport(UIKit)
        setOrientation(from: UIDevice.current)
        #endif

        setupNotifications()
    }

    deinit {
        removeNotifications()
    }

    static let deviceType: DeviceType = {
        #if canImport(UIKit)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .iPad
        }
        return .iPhone
        #else
        return .mac
        #endif
    }()

    private func setupNotifications() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        #endif
    }

    private func removeNotifications() {
        #if canImport(UIKit)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
    }

    #if canImport(UIKit)
    @objc
    private func onOrientationChange(_ notification: Notification) {
        guard let device = notification.object as? UIDevice else { return }

        setOrientation(from: device)
    }
    #endif

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

enum DeviceType {
    case iPhone
    case iPad
    case mac

    var shouldHaveSidebar: Bool {
        self != .iPhone
    }
}
