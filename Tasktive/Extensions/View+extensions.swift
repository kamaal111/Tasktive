//
//  View+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI

extension View {
    #if DEBUG
    func previewEnvironment() -> some View {
        environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(DeviceModel())
            .environmentObject(NamiNavigator())
    }
    #endif
}
