//
//  SettingsScreen.swift
//
//
//  Created by Kamaal M Farah on 12/08/2022.
//

import os.log
import SwiftUI
import Logster
import SalmonUI
import Environment
import TasktiveLocale

private struct EmptyEncodable: Encodable { }
private let logger = Logster(from: SettingsUI.SettingsScreen<EmptyEncodable>.self)

extension SettingsUI {
    public struct SettingsScreen<FeedbackData: Encodable>: View {
        @StateObject private var store: Store

        @Binding public var navigationPath: NavigationPath
        @Binding public var iCloudSyncingIsEnabled: Bool

        public let appColor: Color
        public let defaultAppColor: Color
        public let viewSize: CGSize
        public let feedbackConfiguration: FeedbackConfiguration<FeedbackData>?
        public let onFeedbackSend: (_ maybeError: Error?) -> Void
        public let onColorSelect: (_ color: AppColor) -> Void
        public let onPurchaseFailure: (_ error: Error) -> Void

        public init<T: StoreKitDonatable>(
            navigationPath: Binding<NavigationPath>,
            iCloudSyncingIsEnabled: Binding<Bool>,
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
            self._iCloudSyncingIsEnabled = iCloudSyncingIsEnabled
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
            SettingsScreenView(
                iCloudSyncingIsEnabled: $iCloudSyncingIsEnabled,
                hasDonations: store.hasDonations,
                feedbackConfiguration: feedbackConfiguration
            )
            .onAppear(perform: handleAppear)
            .environmentObject(store)
            .navigationDestination(for: SettingsScreens.self) { screen in
                SettingsStackView(
                    navigationPath: $navigationPath,
                    screen: screen,
                    viewSize: viewSize,
                    appColor: appColor,
                    defaultAppColor: defaultAppColor,
                    feedbackConfiguration: feedbackConfiguration,
                    onFeedbackSend: onFeedbackSend,
                    onColorSelect: onColorSelect,
                    onPurchaseFailure: onPurchaseFailure
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

    private struct SettingsScreenView<T: Encodable>: View {
        @Binding var iCloudSyncingIsEnabled: Bool

        let hasDonations: Bool
        let feedbackConfiguration: FeedbackConfiguration<T>?

        var body: some View {
            KScrollableForm {
                if hasDonations {
                    SupportAuthorSection()
                }
                if showFeedbackSection {
                    FeedbackSection()
                }
                PersonalizationSection()
                if Environment.Features.iCloudSyncing {
                    FeaturesSection(iCloudSyncingIsEnabled: $iCloudSyncingIsEnabled)
                }
                MiscellaneousSection()
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

        @Binding var navigationPath: NavigationPath

        let screen: SettingsScreens
        let viewSize: CGSize
        let appColor: Color
        let defaultAppColor: Color
        let feedbackConfiguration: FeedbackConfiguration<T>?
        let onFeedbackSend: (_ maybeError: Error?) -> Void
        let onColorSelect: (_ color: AppColor) -> Void
        let onPurchaseFailure: (_ error: Error) -> Void

        var body: some View {
            KJustStack {
                switch screen {
                case let .feedback(style: style, predefinedDescription: predefinedDescription):
                    if let configuration = feedbackConfiguration {
                        FeedbackScreen(
                            configuration: configuration,
                            style: style,
                            predefinedDescription: predefinedDescription,
                            onDone: { maybeError in onFeedbackSend(maybeError) }
                        )
                    } else {
                        Text(TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE))
                    }
                case .appColor:
                    AppColorScreen(
                        defaultColor: defaultAppColor,
                        onColorSelect: { color in onColorSelect(color) }
                    )
                case .supportAuthor:
                    SupportAuthorScreen(
                        navigateBack: { navigationPath.removeLast() },
                        handlePurchaseFailure: onPurchaseFailure
                    )
                case .logs:
                    LogsScreen(navigate: { screen in navigationPath.append(screen) })
                case .acknowledgements:
                    AcknowledgementsScreen()
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
