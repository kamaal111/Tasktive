//
//  Rows.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import SwiftUI
import SalmonUI

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
                        Text(buildNumber)
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

    @available(macOS 12.0, *)
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
            RowViewValueButton(action: action, label: label) {
                RowImageTextView(label: label, imageSystemName: imageSystemName)
            }
        }
    }

    @available(macOS 12.0, *)
    public struct RowViewColorView: View {
        public let label: String
        public let color: Color

        public init(label: String, color: Color) {
            self.label = label
            self.color = color
        }

        public var body: some View {
            RowViewValueView(label: label) {
                color
                    .frame(width: 28, height: 28)
                    .cornerRadius(8)
            }
        }
    }

    @available(macOS 12.0, *)
    public struct RowViewColorButton: View {
        public let label: String
        public let color: Color
        public let action: () -> Void

        public init(action: @escaping () -> Void, label: String, color: Color) {
            self.label = label
            self.color = color
            self.action = action
        }

        public var body: some View {
            RowViewValueButton(action: action, label: label) {
                color
                    .frame(width: 28, height: 28)
                    .cornerRadius(8)
            }
        }
    }

    @available(macOS 12.0, *)
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
                #if os(macOS)
                    .background(Color(nsColor: .separatorColor).opacity(0.1))
                #endif
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
