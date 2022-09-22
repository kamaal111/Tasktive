//
//  LogsScreen.swift
//
//
//  Created by Kamaal M Farah on 22/09/2022.
//

import SwiftUI
import Logster
import SalmonUI

extension SettingsUI {
    public struct LogsScreen: View {
        @State private var logs: [HoldedLog] = []

        public init() { }

        public var body: some View {
            KScrollableForm {
                ForEach(logs, id: \.self) { item in
                    HStack(spacing: 8) {
                        Text(item.label)
                            .foregroundColor(item.type.color)
                        Text(item.message)
                            .lineLimit(1)
                    }
                }
            }
            .ktakeSizeEagerly(alignment: .topLeading)
            .onAppear(perform: {
                Task { logs = await LogHolder.shared.logs }
            })
        }
    }
}
