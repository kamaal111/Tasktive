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

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        Form {
            SettingsUI.FeedbackSection(onFeedbackPress: { style in
                stackNavigator.navigate(to: style)
            })
            SettingsUI.AboutSection()
        }
        .navigationDestination(for: FeedbackStyles.self) { style in
            SettingsUI.FeedbackScreen(
                configuration: viewModel.feedbackConfiguration(withStyle: style),
                onDone: onFeedbackSend(_:)
            )
        }
        #if os(macOS)
        .padding(.vertical, .medium)
        .padding(.horizontal, .medium)
        .ktakeSizeEagerly(alignment: .topLeading)
        #endif
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

        func feedbackConfiguration(withStyle style: FeedbackStyles) -> SettingsUI.FeedbackScreen.FeedbackConfiguration {
            .init(
                style: style,
                gitHubToken: TokensHolder.shared.tokens?.gitHubToken ?? "",
                gitHubUsername: Constants.gitHubUsername,
                repoName: Constants.repoName,
                additionalFeedbackData: FeedbackMetadata(),
                additionalIssueLabels: [DeviceModel.deviceType.issueLabel]
            )
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
