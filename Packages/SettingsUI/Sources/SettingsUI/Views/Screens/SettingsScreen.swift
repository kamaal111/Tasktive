//
//  SettingsScreen.swift
//
//
//  Created by Kamaal M Farah on 12/08/2022.
//

import os.log
import SwiftUI
import SalmonUI

@available(macOS 13.0, iOS 16.0, *)
private let logger = Logger(
    subsystem: "io.kamaal.SettingsUI",
    category: String(describing: SettingsUI.SettingsScreen.self)
)

extension SettingsUI {
    @available(macOS 13.0, iOS 16.0, *)
    public struct SettingsScreen: View {
        @StateObject private var store: Store

        @Binding public var navigationPath: NavigationPath

        public let appColor: Color
        public let defaultAppColor: Color
        public let viewSize: CGSize
        public let feedbackConfiguration: FeedbackConfiguration?
        public let onFeedbackSend: (_ maybeError: Error?) -> Void
        public let onColorSelect: (_ color: AppColor) -> Void
        public let onPurchaseFailure: (_ error: Error) -> Void

        public init(
            navigationPath: Binding<NavigationPath>,
            appColor: Color,
            defaultAppColor: Color,
            viewSize: CGSize,
            feedbackConfiguration: FeedbackConfiguration?,
            storeKitDonations: [some StoreKitDonatable],
            onFeedbackSend: @escaping (_: Error?) -> Void,
            onColorSelect: @escaping (_: AppColor) -> Void,
            onPurchaseFailure: @escaping (_ error: Error) -> Void
        ) {
            self._navigationPath = navigationPath
            self.appColor = appColor
            self.defaultAppColor = defaultAppColor
            self.viewSize = viewSize
            self.feedbackConfiguration = feedbackConfiguration
            self.onFeedbackSend = onFeedbackSend
            self.onColorSelect = onColorSelect
            self.onPurchaseFailure = onPurchaseFailure
            self._store = StateObject(wrappedValue: Store(storeKitDonations: storeKitDonations))
        }

        public var body: some View {
            ScrollableForm {
                if store.hasDonations {
                    SupportAuthorSection()
                }
                if showFeedbackSection {
                    FeedbackSection()
                }
                PersonalizationSection()
                AboutSection()
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
                        AppColorScreen(
                            defaultColor: defaultAppColor,
                            onColorSelect: { color in onColorSelect(color) }
                        )
                    case .supportAuthor:
                        SupportAuthorScreen(navigationPath: $navigationPath, handlePurchaseFailure: onPurchaseFailure)
                            .environmentObject(store)
                    }
                }
                .frame(minWidth: viewSize.width, minHeight: viewSize.height)
                .accentColor(appColor)
                .navigationTitle(Text(screen.title))
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
            }
            .onAppear(perform: handleAppear)
            #if os(macOS)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .ktakeSizeEagerly(alignment: .topLeading)
            #endif
        }

        private var showFeedbackSection: Bool {
            feedbackConfiguration?.gitHubToken != nil
        }

        private func handleAppear() {
            Task {
                let result = await store.requestProducts()
                switch result {
                case let .failure(failure):
                    logger
                        .error(
                            "failed to get donations; description='\(failure.localizedDescription)'; error='\(failure)'"
                        )
                case .success:
                    break
                }
            }
        }
    }
}
