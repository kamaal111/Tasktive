//
//  SettingsUI.swift
//
//
//  Created by Kamaal Farah on 24/07/2022.
//

import SwiftUI

/// Base struct to access other views
public struct SettingsUI {
    private init() { }
}

extension SettingsUI {
    /// A row with the bundle version and build number in it
    public struct VersionRowView: View {
        /// View initializer
        public init() { }

        public var body: some View {
            if let versionText = versionText {
                RowViewValueView(label: NSLocalizedString("Version", bundle: .module, comment: "")) {
                    Text(versionText)
                    if let buildNumber = buildNumber {
                        Text("(\(buildNumber))")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
            }
        }

        private var versionText: String? {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        }

        private var buildNumber: String? {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        }
    }

    public struct RowViewValueView<Value: View>: View {
        public let label: String
        public let value: Value

        public init(label: String, @ViewBuilder value: () -> Value) {
            self.label = label
            self.value = value()
        }

        public var body: some View {
            RowView(label: {
                Text(label)
            }, value: {
                value
            })
        }
    }

    public struct RowView<Label: View, Value: View>: View {
        public let label: Label
        public let value: Value

        public init(@ViewBuilder label: () -> Label, @ViewBuilder value: () -> Value) {
            self.label = label()
            self.value = value()
        }

        public var body: some View {
            HStack {
                label
                    .font(.headline)
                Spacer()
                value
            }
        }
    }
}
