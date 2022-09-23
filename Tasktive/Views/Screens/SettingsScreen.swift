//
//  SettingsScreen.swift
//  Tasktive
//
//  Created by Kamaal Farah on 24/07/2022.
//

import SwiftUI
import Logster
import SalmonUI
import PopperUp
import SettingsUI
import TasktiveLocale

private let SCREEN: NamiNavigator.Screens = .settings
private let logger = Logster(from: SettingsScreen.self)

struct SettingsScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var popperUpManager: PopperUpManager
    @EnvironmentObject private var stackNavigator: StackNavigator
    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var userData: UserData

    var body: some View {
        SettingsUI.SettingsScreen(
            navigationPath: $stackNavigator.path,
            iCloudSyncingIsEnabled: $userData.iCloudSyncingIsEnabled,
            appColor: theme.currentAccentColor(scheme: colorScheme),
            defaultAppColor: .AccentColor,
            viewSize: Constants.UI.settingsViewMinimumSize,
            feedbackConfiguration: feedbackConfiguration,
            storeKitDonations: Constants.donations,
            onFeedbackSend: onFeedbackSend(_:),
            onColorSelect: onColorSelect(_:),
            onPurchaseFailure: onPurchaseFailure(_:)
        )
    }

    private var feedbackConfiguration: FeedbackConfiguration<FeedbackMetadata>? {
        guard let gitHubToken = gitHubToken else { return nil }

        return .init(
            gitHubToken: gitHubToken,
            gitHubUsername: Constants.gitHubUsername,
            repoName: Constants.repoName,
            additionalFeedbackData: FeedbackMetadata(),
            additionalIssueLabels: [DeviceModel.deviceType.issueLabel]
        )
    }

    private var gitHubToken: String? {
        TokensHolder.shared.tokens?.gitHubToken
    }

    private func onPurchaseFailure(_ error: Error) {
        logger.error(label: "failed to purchase", error: error)
        popperUpManager.showPopup(
            style: .bottom(
                title: TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE),
                type: .error,
                description: TasktiveLocale.getText(.PURCHASE_ERROR_DESCRIPTION)
            ),
            timeout: 3
        )
    }

    private func onColorSelect(_ color: AppColor) {
        theme.setAppColor(color)
        stackNavigator.goBack()
    }

    private func onFeedbackSend(_ maybeError: Error?) {
        if let error = maybeError {
            logger.error(label: "error while sending feedback", error: error)
            popperUpManager.showPopup(
                style: .bottom(
                    title: TasktiveLocale.getText(.SOMETHING_WENT_WRONG_ERROR_TITLE),
                    type: .error,
                    description: TasktiveLocale.getText(.FEEDBACK_ERROR_DESCRIPTION)
                ), timeout: 3
            )
            return
        }

        stackNavigator.goBack()
        popperUpManager.showPopup(
            style: .bottom(title: TasktiveLocale.getText(.FEEDBACK_SENT), type: .success, description: nil),
            timeout: 3
        )
    }
}

#if DEBUG
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        var configuration = PreviewConfiguration()
        configuration.screen = SCREEN

        return ForEach(ColorScheme.allCases, id: \.self) { scheme in
            MainView()
                .previewEnvironment(withConfiguration: configuration)
                .colorScheme(scheme)
        }
    }
}
#endif
