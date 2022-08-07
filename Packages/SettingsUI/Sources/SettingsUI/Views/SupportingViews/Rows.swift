//
//  Rows.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import SwiftUI

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

    public struct RowImageTextButton: View {
        public let label: String
        public let imageSystemName: String
        public let action: () -> Void

        public init(action: @escaping () -> Void, label: String, imageSystemName: String) {
            self.action = action
            self.label = label
            self.imageSystemName = imageSystemName
        }

        public var body: some View {
            Button(action: action) {
                RowImageTextView(label: label, imageSystemName: imageSystemName)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
    }

    public struct RowViewValueButton<Value: View>: View {
        public let label: String
        public let value: Value
        public let action: () -> Void

        public init(action: @escaping () -> Void, label: String, @ViewBuilder value: () -> Value) {
            self.action = action
            self.label = label
            self.value = value()
        }

        public var body: some View {
            Button(action: action) {
                RowViewValueView(label: label, value: {
                    value
                })
                .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
    }

    public struct RowImageTextView: View {
        public let label: String
        public let imageSystemName: String

        public init(label: String, imageSystemName: String) {
            self.label = label
            self.imageSystemName = imageSystemName
        }

        public var body: some View {
            RowViewValueView(label: label) {
                Image(systemName: imageSystemName)
            }
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
            .padding(.vertical, 1)
        }
    }
}
