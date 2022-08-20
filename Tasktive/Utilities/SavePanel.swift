//
//  SavePanel.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import Foundation
#if canImport(Cocoa)
import Cocoa
#endif

/// Utility struct to handle saving files on users machine
struct SavePanel {
    private init() { }

    #if canImport(Cocoa)
    /// Lets you save items using `NSSavePanel`.
    /// - Parameter filename: Name of file to save.
    /// - Returns: Result to reference location to save and panel.
    public static func savePanel(filename: String) async -> (NSApplication.ModalResponse, NSSavePanel) {
        await withCheckedContinuation { continuation in
            save(filename: filename) { result, panel in
                continuation.resume(returning: (result, panel))
            }
        }
    }

    /// Lets you save items using `NSSavePanel`.
    /// - Parameters:
    ///   - filename: Name of file to save.
    ///   - beginHandler: Closure to access the location to save a asset.
    static func save(
        filename: String,
        beginHandler: @escaping (_ result: NSApplication.ModalResponse, _ panel: NSSavePanel) -> Void
    ) {
        DispatchQueue.main.async {
            let panel = NSSavePanel()
            panel.canCreateDirectories = true
            panel.showsTagField = true
            panel.nameFieldStringValue = filename
            panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
            panel.begin(completionHandler: { result in
                beginHandler(result, panel)
            })
        }
    }
    #endif
}
