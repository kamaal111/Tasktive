//
//  SettingsScreen.swift
//  Tasktive
//
//  Created by Kamaal Farah on 24/07/2022.
//

import SwiftUI
import SalmonUI
import PopperUp
import SettingsUI
import TasktiveLocale

private let SCREEN: NamiNavigator.Screens = .settings
private let logger = Logster(from: SettingsScreen.self)

struct SettingsScreen: View {
    @EnvironmentObject private var popperUpManager: PopperUpManager
    @EnvironmentObject private var stackNavigator: StackNavigator
    @EnvironmentObject private var theme: Theme

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        SettingsUI.SettingsScreen(
            appColor: theme.currentAccentColor,
            defaultAppColor: .AccentColor,
            viewSize: Constants.UI.settingsViewMinimumSize,
            feedbackConfiguration: viewModel.feedbackConfiguration,
            onFeedbackSend: onFeedbackSend(_:),
            onColorSelect: onColorSelect(_:)
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

extension SettingsScreen {
    final class ViewModel: ObservableObject {
        init() { }

        var feedbackConfiguration: FeedbackConfiguration? {
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
    }
}

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
