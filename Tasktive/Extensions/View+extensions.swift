//
//  View+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import Logster
import SalmonUI
#if DEBUG
import PopperUp
#endif

extension View {
    func padding(_ edges: Edge.Set = .all, _ length: AppSizes) -> some View {
        padding(edges, length.rawValue)
    }

    func cornerRadius(_ length: AppSizes) -> some View {
        cornerRadius(length.rawValue)
    }

    #if canImport(Cocoa) && !targetEnvironment(macCatalyst)
    func snapshot() -> NSImage {
        let controller = NSHostingController(rootView: self)
        let view = controller.view

        let targetSize = view.intrinsicContentSize
        let targetPoint = CGPoint(x: -(targetSize.width / 2), y: -(targetSize.height / 2))
        let targetBounds = CGRect(origin: targetPoint, size: targetSize)
        guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: targetBounds)
        else {
            Logster.general.error("could not get bitmap representation")
            return NSImage()
        }
        bitmapRep.size = targetSize
        view.cacheDisplay(in: targetBounds, to: bitmapRep)

        let image = NSImage(size: targetSize)
        image.addRepresentation(bitmapRep)

        return image
    }
    #endif

    #if DEBUG
    func previewEnvironment(withConfiguration configuration: PreviewConfiguration? = nil) -> some View {
        let namiNavigator = NamiNavigator()

        if let configuration = configuration {
            if let screen = configuration.screen {
                namiNavigator.tabSelection = screen
                namiNavigator.sidebarSelection = screen
            }
        }

        return environmentObject(DeviceModel())
            .environmentObject(namiNavigator)
            .environmentObject(TasksViewModel(preview: true))
            .withPopperUp(PopperUpManager(config: .init()))
    }
    #endif
}

#if DEBUG
struct PreviewConfiguration {
    var screen: NamiNavigator.Screens?

    init() { }
}
#endif
