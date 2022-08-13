//
//  SettingsScreen.swift
//
//
//  Created by Kamaal M Farah on 12/08/2022.
//

import SwiftUI
import SalmonUI

extension SettingsUI {
    @available(macOS 13.0, iOS 16.0, *)
    public struct SettingsScreen: View {
        @StateObject private var store = Store()

        public let appColor: Color
        public let defaultAppColor: Color
        public let viewSize: CGSize
        public let feedbackConfiguration: FeedbackConfiguration?
        public let onFeedbackSend: (_ maybeError: Error?) -> Void
        public let onColorSelect: (_ color: AppColor) -> Void

        public init(
            appColor: Color,
            defaultAppColor: Color,
            viewSize: CGSize,
            feedbackConfiguration: FeedbackConfiguration?,
            onFeedbackSend: @escaping (_: Error?) -> Void,
            onColorSelect: @escaping (_: AppColor) -> Void
        ) {
            self.appColor = appColor
            self.defaultAppColor = defaultAppColor
            self.viewSize = viewSize
            self.feedbackConfiguration = feedbackConfiguration
            self.onFeedbackSend = onFeedbackSend
            self.onColorSelect = onColorSelect
        }

        public var body: some View {
            Form {
                if store.hasDonations { }
                if showFeedbackSection {
                    SettingsUI.FeedbackSection()
                }
                SettingsUI.PersonalizationSection()
                SettingsUI.AboutSection()
            }
            .navigationDestination(for: SettingsScreens.self) { screen in
                KJustStack {
                    switch screen {
                    case let .feedback(style: style):
                        if let configuration = feedbackConfiguration {
                            SettingsUI.FeedbackScreen(
                                configuration: configuration,
                                style: style,
                                onDone: { maybeError in onFeedbackSend(maybeError) }
                            )
                        } else {
                            Text(NSLocalizedString("Sorry something went wrong", bundle: .module, comment: ""))
                        }
                    case .appColor:
                        SettingsUI.AppColorScreen(
                            defaultColor: defaultAppColor,
                            onColorSelect: { color in onColorSelect(color) }
                        )
                    }
                }
                .frame(minWidth: viewSize.width, minHeight: viewSize.height)
                .accentColor(appColor)
            }
            #if os(macOS)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .ktakeSizeEagerly(alignment: .topLeading)
            #endif
        }

        private var showFeedbackSection: Bool {
            feedbackConfiguration?.gitHubToken != nil
        }
    }
}
