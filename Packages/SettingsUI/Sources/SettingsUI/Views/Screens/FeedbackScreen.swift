//
//  FeedbackScreen.swift
//
//
//  Created by Kamaal M Farah on 06/08/2022.
//

import SwiftUI

extension SettingsUI {
    public struct FeedbackScreen: View {
        public let style: FeedbackStyles

        public init(style: FeedbackStyles) {
            self.style = style
        }

        public var body: some View {
            Text(style.title)
                .navigationTitle(Text(NSLocalizedString("Feedback", bundle: .module, comment: "")))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
