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
    public struct SettingsScreen<FeedbackData: Encodable>: View {
        @StateObject private var store: Store

        @Binding public var navigationPath: NavigationPath

        public let appColor: Color
        public let defaultAppColor: Color
        public let viewSize: CGSize
        public let feedbackConfiguration: FeedbackConfiguration<FeedbackData>?
        public let onFeedbackSend: (_ maybeError: Error?) -> Void
        public let onColorSelect: (_ color: AppColor) -> Void
        public let onPurchaseFailure: (_ error: Error) -> Void

        public init<T: StoreKitDonatable>(
            navigationPath: Binding<NavigationPath>,
            appColor: Color,
            defaultAppColor: Color,
            viewSize: CGSize,
            feedbackConfiguration: FeedbackConfiguration<FeedbackData>?,
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
            SettingsScreenView(hasDonations: store.hasDonations, feedbackConfiguration: feedbackConfiguration)
                .onAppear(perform: handleAppear)
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
                    .environmentObject(store)
                }
        }

        private func handleAppear() {
            Task {
                _ = try? await store.requestProducts().get()
            }
        }
    }
    #else
    public struct SettingsScreen<FeedbackData: Encodable>: View {
        @Environment(\.presentationMode) private var presentationMode

        @StateObject private var store: Store

        @State private var currentScreen: SettingsScreens?

        public let appColor: Color
        public let defaultAppColor: Color
        public let viewSize: CGSize
        public let feedbackConfiguration: FeedbackConfiguration<FeedbackData>?
        public let onFeedbackSend: (_ maybeError: Error?) -> Void
        public let onColorSelect: (_ color: AppColor) -> Void
        public let onPurchaseFailure: (_ error: Error) -> Void

        public init<DonationType: StoreKitDonatable>(
            appColor: Color,
            defaultAppColor: Color,
            viewSize: CGSize,
            feedbackConfiguration: FeedbackConfiguration<FeedbackData>?,
            storeKitDonations: [DonationType],
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
                    NavigationLink(tag: screen, selection: $currentScreen, destination: {
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
                    }, label: { EmptyView() })
                }
                SettingsScreenView(
                    feedbackConfiguration: feedbackConfiguration,
                    hasDonations: store.hasDonations,
                    onNavigate: { screen in
                        currentScreen = screen
                    }
                )
                .environmentObject(store)
            }
            .onAppear(perform: handleAppear)
        }

        private func handleAppear() {
            Task {
                _ = try? await store.requestProducts().get()
            }
        }
    }
    #endif

    private struct SettingsScreenView<T: Encodable>: View {
        let hasDonations: Bool
        let feedbackConfiguration: FeedbackConfiguration<T>?
        #if swift(<5.7)
        let onNavigate: (_ screen: SettingsScreens) -> Void
        #endif

        private let logger = Logger(
            subsystem: "io.kamaal.SettingsUI",
            category: "SettingsScreen"
        )

        var body: some View {
            KScrollableForm {
                if hasDonations {
                    #if swift(>=5.7)
                    SupportAuthorSection()
                    #else
                    SupportAuthorSection(onNavigate: onNavigate)
                    #endif
                }
                if showFeedbackSection {
                    #if swift(>=5.7)
                    FeedbackSection()
                    #else
                    FeedbackSection(onNavigate: onNavigate)
                    #endif
                }
                #if swift(>=5.7)
                PersonalizationSection()
                #else
                PersonalizationSection(onNavigate: onNavigate)
                #endif
                AboutSection()
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

    private struct SettingsStackView<T: Encodable>: View {
        @EnvironmentObject private var store: Store

        let screen: SettingsScreens
        let viewSize: CGSize
        let appColor: Color
        let defaultAppColor: Color
        let feedbackConfiguration: FeedbackConfiguration<T>?
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
