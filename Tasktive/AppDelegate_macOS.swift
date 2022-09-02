//
//  AppDelegate_macOS.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 14/08/2022.
//

#if os(macOS)
import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let application = notification.object as? NSApplication else { return }
        application.registerForRemoteNotifications()
    }
}
#endif
