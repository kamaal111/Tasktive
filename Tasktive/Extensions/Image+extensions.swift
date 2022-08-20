//
//  Image+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import SwiftUI

#if canImport(Cocoa) && !targetEnvironment(macCatalyst)
extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }

    func download(filename: String) async {
        guard let pngData = pngData else { return }
        await pngData.download(filename: filename)
    }
}
#endif
