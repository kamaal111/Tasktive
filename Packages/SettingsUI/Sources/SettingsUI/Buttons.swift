//
//  Buttons.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import SwiftUI

extension SettingsUI {
    public struct SettingsButton<Content: View>: View {
        #if os(macOS)
        @Environment(\.isEnabled) private var isEnabled
        #endif

        public let action: () -> Void
        public let content: Content

        public init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
            self.action = action
            self.content = content()
        }

        public var body: some View {
            Button(action: action) {
                content
            }
            #if os(macOS)
            .foregroundColor(!isEnabled ? .secondary : .accentColor)
            #else
            .foregroundColor(.accentColor)
            #endif
            .buttonStyle(.plain)
        }
    }
}
