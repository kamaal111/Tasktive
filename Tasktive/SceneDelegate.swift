//
//  SceneDelegate.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 29/08/2022.
//

import UIKit

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        #if DEBUG
        if let windowScene = scene as? UIWindowScene {
            windowScene.windows.forEach { window in
                if CommandLineArguments.uiTestingDarkMode.enabled {
                    window.overrideUserInterfaceStyle = .dark
                } else if CommandLineArguments.uiTestingLightMode.enabled {
                    window.overrideUserInterfaceStyle = .light
                }
            }
        }
        #endif
    }
}
