//
//  Sections.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import SwiftUI
import SalmonUI

extension SettingsUI {
    @available(macOS 13.0, iOS 16.0, *)
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

    @available(macOS 13.0, iOS 16.0, *)
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

    @available(macOS 13.0, iOS 16.0, *)
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
