//
//  Sections.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import SwiftUI
import SalmonUI

extension SettingsUI {
    public struct SupportAuthorSection: View {
        public init() { }

        public var body: some View {
            KSection(header: NSLocalizedString("Support Author", bundle: .module, comment: "")) {
                RowImageTextNavigationLink(
                    label: NSLocalizedString("Buy me coffee", bundle: .module, comment: ""),
                    imageSystemName: "cup.and.saucer.fill",
                    destination: .supportAuthor
                )
            }
        }
    }

    public struct AboutSection: View {
        public init() { }

        public var body: some View {
            KSection(header: NSLocalizedString("About", bundle: .module, comment: "")) {
                VersionRowView()
            }
        }
    }

    public struct PersonalizationSection: View {
        public init() { }

        public var body: some View {
            KSection(header: NSLocalizedString("Personalization", bundle: .module, comment: "")) {
                RowViewColorNavigationLink(
                    label: SettingsScreens.appColor.title,
                    color: .accentColor,
                    destination: .appColor
                )
            }
        }
    }

    public struct FeaturesSection: View {
        @Binding public var iCloudSyncingIsEnabled: Bool

        public init(iCloudSyncingIsEnabled: Binding<Bool>) {
            self._iCloudSyncingIsEnabled = iCloudSyncingIsEnabled
        }

        public var body: some View {
            KSection(header: NSLocalizedString("Features", bundle: .module, comment: "")) {
                HStack {
                    Text(NSLocalizedString("iCloud syncing", bundle: .module, comment: ""))
                        .bold()
                        .foregroundColor(.accentColor)
                    Spacer()
                    Toggle(isOn: $iCloudSyncingIsEnabled) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
    }

    public struct FeedbackSection: View {
        public init() { }

        public var body: some View {
            KSection(header: NSLocalizedString("Feedback", bundle: .module, comment: "")) {
                feedbackButton(.feature, withDivider: true)
                feedbackButton(.bug, withDivider: true)
                feedbackButton(.other, withDivider: false)
            }
        }

        private func feedbackButton(_ style: FeedbackStyles, withDivider: Bool) -> some View {
            VStack {
                RowImageTextNavigationLink(
                    label: style.title,
                    imageSystemName: style.imageSystemName,
                    destination: .feedback(style: style)
                )
                #if os(macOS)
                if withDivider {
                    Divider()
                }
                #endif
            }
        }
    }
}
