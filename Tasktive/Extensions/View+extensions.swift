//
//  View+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI

extension View {
    func padding(_ edges: Edge.Set = .all, _ length: AppSizes) -> some View {
        padding(edges, length.rawValue)
    }

    #if DEBUG
    func previewEnvironment() -> some View {
        environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(DeviceModel())
            .environmentObject(NamiNavigator())
    }
    #endif
}
