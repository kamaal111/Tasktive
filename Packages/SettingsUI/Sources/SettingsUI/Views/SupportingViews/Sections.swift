//
//  Sections.swift
//
//
//  Created by Kamaal M Farah on 30/07/2022.
//

import SwiftUI
import SalmonUI

extension SettingsUI {
    @available(macOS 12.0, *)
    public struct AboutSection: View {
        public init() { }

        public var body: some View {
            SectionView(header: NSLocalizedString("About", bundle: .module, comment: "")) {
                VersionRowView()
            }
        }
    }

    @available(macOS 13.0, *)
    public struct PersonalizationSection: View {
        private let label = NSLocalizedString("Change app color", bundle: .module, comment: "")
        private let color: Color = .accentColor

        public init() { }

        public var body: some View {
            SectionView(header: NSLocalizedString("Personalization", bundle: .module, comment: "")) {
                NavigationLink(value: SettingsScreens.appColor) {
                    RowViewColorView(label: label, color: color)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @available(macOS 13.0, *)
    public struct FeedbackSection: View {
        public init() { }

        public var body: some View {
            SectionView(header: NSLocalizedString("Feedback", bundle: .module, comment: "")) {
                ForEach(FeedbackStyles.allCases, id: \.self) { style in
                    VStack {
                        NavigationLink(value: SettingsScreens.feedback(style: style)) {
                            RowImageTextView(label: style.title, imageSystemName: style.imageSystemName)
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
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

    @available(macOS 12.0, *)
    public struct SectionView<Content: View>: View {
        public let header: String?
        public let content: Content

        public init(header: String? = nil, @ViewBuilder content: () -> Content) {
            self.header = header?.uppercased()
            self.content = content()
        }

        public var body: some View {
            KJustStack {
                if let header = header {
                    #if os(macOS)
                    VStack {
                        Text(header)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .ktakeWidthEagerly(alignment: .leading)
                        content
                    }
                    #else
                    Section(header: Text(header)) {
                        content
                    }
                    #endif
                } else {
                    #if os(macOS)
                    content
                    #else
                    Section {
                        content
                    }
                    #endif
                }
            }
            #if os(macOS)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(nsColor: .separatorColor))
            .cornerRadius(8)
            #endif
        }
    }
}
