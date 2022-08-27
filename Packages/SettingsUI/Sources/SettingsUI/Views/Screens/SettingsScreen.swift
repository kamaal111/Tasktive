//
//  SettingsScreen.swift
//
//
//  Created by Kamaal M Farah on 12/08/2022.
//

import os.log
import SwiftUI
import SalmonUI

extension SettingsUI {
    #if swift(>=5.7)
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

        public init<T: StoreKitDonatable>(
            navigationPath: Binding<NavigationPath>,
            appColor: Color,
            defaultAppColor: Color,
            viewSize: CGSize,
            feedbackConfiguration: FeedbackConfiguration?,
            storeKitDonations: [T],
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
            SettingsScreenView(feedbackConfiguration: feedbackConfiguration)
                .environmentObject(store)
                .navigationDestination(for: SettingsScreens.self) { screen in
                    SettingsStackView(
                        screen: screen,
                        viewSize: viewSize,
                        appColor: appColor,
                        defaultAppColor: defaultAppColor,
                        feedbackConfiguration: feedbackConfiguration,
                        onFeedbackSend: onFeedbackSend,
                        onColorSelect: onColorSelect,
                        onPurchaseFailure: onPurchaseFailure,
                        navigationPath: { navigationPath.removeLast() }
                    )
                }
        }
    }
    #else
    public struct SettingsScreen: View {
        @Environment(\.presentationMode) private var presentationMode

        @StateObject private var store: Store

        public let appColor: Color
        public let defaultAppColor: Color
        public let viewSize: CGSize
        public let feedbackConfiguration: FeedbackConfiguration?
        public let onFeedbackSend: (_ maybeError: Error?) -> Void
        public let onColorSelect: (_ color: AppColor) -> Void
        public let onPurchaseFailure: (_ error: Error) -> Void

        public init<T: StoreKitDonatable>(
            appColor: Color,
            defaultAppColor: Color,
            viewSize: CGSize,
            feedbackConfiguration: FeedbackConfiguration?,
            storeKitDonations: [T],
            onFeedbackSend: @escaping (_: Error?) -> Void,
            onColorSelect: @escaping (_: AppColor) -> Void,
            onPurchaseFailure: @escaping (_ error: Error) -> Void
        ) {
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
            ZStack {
                ForEach(SettingsScreens.allCases, id: \.self) { screen in
                    NavigationLink(destination: {
                        SettingsStackView(
                            screen: screen,
                            viewSize: viewSize,
                            appColor: appColor,
                            defaultAppColor: defaultAppColor,
                            feedbackConfiguration: feedbackConfiguration,
                            onFeedbackSend: onFeedbackSend,
                            onColorSelect: onColorSelect,
                            onPurchaseFailure: onPurchaseFailure,
                            navigationPath: { presentationMode.wrappedValue.dismiss() }
                        )
                    }) {
                        EmptyView()
                    }
                }
                SettingsScreenView(feedbackConfiguration: feedbackConfiguration)
                    .environmentObject(store)
            }
        }
    }
    #endif

    private struct SettingsScreenView: View {
        @EnvironmentObject private var store: Store

        let feedbackConfiguration: FeedbackConfiguration?

        private let logger = Logger(
            subsystem: "io.kamaal.SettingsUI",
            category: "SettingsScreen"
        )

        var body: some View {
            KScrollableForm {
                if store.hasDonations {
                    SupportAuthorSection()
                }
                if showFeedbackSection {
                    FeedbackSection()
                }
                PersonalizationSection()
                AboutSection()
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
                    let message =
                        "failed to get donations; description='\(failure.localizedDescription)'; error='\(failure)'"
                    logger.error("\(message)")
                case .success:
                    break
                }
            }
        }
    }

    private struct SettingsStackView: View {
        @EnvironmentObject private var store: Store

        let screen: SettingsScreens
        let viewSize: CGSize
        let appColor: Color
        let defaultAppColor: Color
        let feedbackConfiguration: FeedbackConfiguration?
        let onFeedbackSend: (_ maybeError: Error?) -> Void
        let onColorSelect: (_ color: AppColor) -> Void
        let onPurchaseFailure: (_ error: Error) -> Void
        let navigationPath: () -> Void

        var body: some View {
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
                    SupportAuthorScreen(navigateBack: navigationPath, handlePurchaseFailure: onPurchaseFailure)
                }
            }
            .frame(minWidth: viewSize.width, minHeight: viewSize.height)
            .accentColor(appColor)
            .navigationTitle(Text(screen.title))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
