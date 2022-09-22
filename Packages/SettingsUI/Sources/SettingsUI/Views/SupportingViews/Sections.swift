//
//  Sections.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale

extension SettingsUI {
    public struct MiscellaneousSection: View {
        public init() { }

        public var body: some View {
            KSection(header: TasktiveLocale.getText(.MISCELLANEOUS)) {
                RowImageTextNavigationLink(
                    label: TasktiveLocale.getText(.LOGS),
                    imageSystemName: "newspaper.fill",
                    destination: .logs
                )
            }
        }
    }

    public struct SupportAuthorSection: View {
        public init() { }

        public var body: some View {
            KSection(header: TasktiveLocale.getText(.SUPPORT_AUTHOR)) {
                RowImageTextNavigationLink(
                    label: TasktiveLocale.getText(.BUY_ME_COFFEE),
                    imageSystemName: "cup.and.saucer.fill",
                    destination: .supportAuthor
                )
            }
        }
    }

    public struct AboutSection: View {
        public init() { }

        public var body: some View {
            KSection(header: TasktiveLocale.getText(.ABOUT)) {
                VersionRowView()
            }
        }
    }

    public struct PersonalizationSection: View {
        public init() { }

        public var body: some View {
            KSection(header: TasktiveLocale.getText(.PERSONALIZATION)) {
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
            KSection(header: TasktiveLocale.getText(.FEATURES)) {
                HStack {
                    Text(TasktiveLocale.getText(.ICLOUD_SYNCING))
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
            KSection(header: TasktiveLocale.getText(.FEEDBACK)) {
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
