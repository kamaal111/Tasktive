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
        #if swift(>=5.7)
        public init() { }
        #else
        public let onNavigate: (_ screen: SettingsScreens) -> Void

        public init(onNavigate: @escaping (_ screen: SettingsScreens) -> Void) {
            self.onNavigate = onNavigate
        }
        #endif

        public var body: some View {
            KSection(header: NSLocalizedString("Support Author", bundle: .module, comment: "")) {
                #if swift(>=5.7)
                RowImageTextNavigationLink(
                    label: NSLocalizedString("Buy me coffee", bundle: .module, comment: ""),
                    imageSystemName: "cup.and.saucer.fill",
                    destination: .supportAuthor
                )
                #else
                RowImageTextNavigationLink(
                    label: NSLocalizedString("Buy me coffee", bundle: .module, comment: ""),
                    imageSystemName: "cup.and.saucer.fill",
                    destination: .supportAuthor,
                    onNavigate: onNavigate
                )
                #endif
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
        #if swift(>=5.7)
        public init() { }
        #else
        public let onNavigate: (_ screen: SettingsScreens) -> Void

        public init(onNavigate: @escaping (_ screen: SettingsScreens) -> Void) {
            self.onNavigate = onNavigate
        }
        #endif

        public var body: some View {
            KSection(header: NSLocalizedString("Personalization", bundle: .module, comment: "")) {
                #if swift(>=5.7)
                RowViewColorNavigationLink(
                    label: SettingsScreens.appColor.title,
                    color: .accentColor,
                    destination: .appColor
                )
                #else
                RowViewColorNavigationLink(
                    label: SettingsScreens.appColor.title,
                    color: .accentColor,
                    destination: .appColor,
                    onNavigate: onNavigate
                )
                #endif
            }
        }
    }

    public struct FeedbackSection: View {
        #if swift(>=5.7)
        public init() { }
        #else
        public let onNavigate: (_ screen: SettingsScreens) -> Void

        public init(onNavigate: @escaping (_ screen: SettingsScreens) -> Void) {
            self.onNavigate = onNavigate
        }
        #endif

        public var body: some View {
            KSection(header: NSLocalizedString("Feedback", bundle: .module, comment: "")) {
                ForEach(FeedbackStyles.allCases, id: \.self) { style in
                    VStack {
                        #if swift(>=5.7)
                        RowImageTextNavigationLink(
                            label: style.title,
                            imageSystemName: style.imageSystemName,
                            destination: .feedback(style: style)
                        )
                        #else
                        RowImageTextNavigationLink(
                            label: style.title,
                            imageSystemName: style.imageSystemName,
                            destination: .feedback(style: style),
                            onNavigate: onNavigate
                        )
                        #endif
                        #if os(macOS)
                        if style != FeedbackStyles.allCases.last {
                            Divider()
                        }
                        #endif
                    }
                }
            }
        }
    }
}
