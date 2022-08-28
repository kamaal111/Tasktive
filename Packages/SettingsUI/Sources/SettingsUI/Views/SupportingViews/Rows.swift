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

    public struct RowViewColorNavigationLink: View {
        public let label: String
        public let color: Color
        public let destination: SettingsScreens
        public let onNavigate: (_ destination: SettingsScreens) -> Void

        #if swift(>=5.7)
        public init(label: String, color: Color, destination: SettingsScreens) {
            self.label = label
            self.color = color
            self.destination = destination
            self.onNavigate = { _ in }
        }
        #else
        public init(
            label: String,
            color: Color,
            destination: SettingsScreens,
            onNavigate: @escaping (_ destination: SettingsScreens) -> Void
        ) {
            self.label = label
            self.color = color
            self.destination = destination
            self.onNavigate = onNavigate
        }
        #endif

        public var body: some View {
            #if swift(>=5.7)
            RowNavigationLink(destination: destination) {
                RowViewColorView(label: label, color: color)
            }
            #else
            RowNavigationLink(onNavigate: onNavigate, destination: destination) {
                RowViewColorView(label: label, color: color)
            }
            #endif
        }
    }

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
                    // Hack: need the following 2 lines to be fully clickable on macOS
                    .ktakeWidthEagerly()
                    .background(Color(nsColor: .separatorColor).opacity(0.01))
                #endif
            }
            .buttonStyle(.plain)
        }
    }

    public struct RowImageTextNavigationLink: View {
        public let label: String
        public let imageSystemName: String
        public let destination: SettingsScreens
        public let onNavigate: (_ destination: SettingsScreens) -> Void

        #if swift(>=5.7)
        public init(label: String, imageSystemName: String, destination: SettingsScreens) {
            self.label = label
            self.imageSystemName = imageSystemName
            self.destination = destination
            self.onNavigate = { _ in }
        }
        #else
        public init(
            label: String,
            imageSystemName: String,
            destination: SettingsScreens,
            onNavigate: @escaping (_ destination: SettingsScreens) -> Void
        ) {
            self.label = label
            self.imageSystemName = imageSystemName
            self.destination = destination
            self.onNavigate = onNavigate
        }
        #endif

        public var body: some View {
            #if swift(>=5.7)
            RowNavigationLink(destination: destination) {
                RowImageTextView(label: label, imageSystemName: imageSystemName)
            }
            #else
            RowNavigationLink(onNavigate: onNavigate, destination: destination) {
                RowImageTextView(label: label, imageSystemName: imageSystemName)
            }
            #endif
        }
    }

    public struct RowNavigationLink<Value: View>: View {
        public let destination: SettingsScreens
        public let value: Value
        public let onNavigate: (_ destination: SettingsScreens) -> Void

        #if swift(>=5.7)
        public init(destination: SettingsScreens, @ViewBuilder value: () -> Value) {
            self.destination = destination
            self.value = value()
            self.onNavigate = { _ in }
        }
        #else
        public init(
            onNavigate: @escaping (_ destination: SettingsScreens) -> Void,
            destination: SettingsScreens,
            @ViewBuilder value: () -> Value
        ) {
            self.destination = destination
            self.value = value()
            self.onNavigate = onNavigate
        }
        #endif

        public var body: some View {
            KJustStack {
                #if swift(>=5.7)
                if #available(macOS 13.0, iOS 16.0, *) {
                    NavigationLink(value: destination) {
                        content
                    }
                } else {
                    fallbackView
                }
                #else
                fallbackView
                #endif
            }
            .buttonStyle(.plain)
        }

        private var fallbackView: some View {
            Button(action: { onNavigate(destination) }) {
                content
            }
        }

        private var content: some View {
            value
                .foregroundColor(.accentColor)
            #if os(macOS)
                // Hack: need the following 2 lines to be fully clickable on macOS
                .ktakeWidthEagerly()
                .background(Color(nsColor: .separatorColor).opacity(0.01))
            #endif
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
