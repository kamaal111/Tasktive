//
//  FeedbackScreen.swift
//
//
//  Created by Kamaal M Farah on 06/08/2022.
//

import SwiftUI
import SalmonUI
import GitHubAPI

extension SettingsUI {
    public struct FeedbackScreen: View {
        @Environment(\.colorScheme) private var colorScheme

        @StateObject private var viewModel: ViewModel

        public let onDone: (_ maybeError: Error?) -> Void

        public init(
            configuration: FeedbackConfiguration,
            style: FeedbackStyles,
            onDone: @escaping (_ maybeError: Error?) -> Void
        ) {
            self._viewModel = StateObject(wrappedValue: ViewModel(configuration: configuration, style: style))
            self.onDone = onDone
        }

        public var body: some View {
            VStack {
                KFloatingTextField(
                    text: $viewModel.title,
                    title: NSLocalizedString("Title", bundle: .module, comment: "")
                )
                KTextView(
                    text: $viewModel.description,
                    title: NSLocalizedString("Description", bundle: .module, comment: "")
                )
                Button(action: onSendPress) {
                    Text(NSLocalizedString("Send", bundle: .module, comment: ""))
                        .font(.headline)
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(.vertical, 4)
                        .ktakeWidthEagerly()
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.disableSubmit)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }

        private func onSendPress() {
            Task {
                do {
                    try await viewModel.submit()
                } catch {
                    onDone(error)
                    return
                }
                onDone(nil)
            }
        }
    }
}

extension SettingsUI.FeedbackScreen {
    final class ViewModel: ObservableObject {
        @Published var title = ""
        @Published var description = ""
        @Published var loading = false

        let configuration: FeedbackConfiguration
        let style: FeedbackStyles

        private var gitHubAPI: GitHubAPI?

        init(configuration: FeedbackConfiguration, style: FeedbackStyles) {
            self.configuration = configuration
            self.style = style
            self.gitHubAPI = .init(token: configuration.gitHubToken, username: configuration.gitHubUsername)
        }

        var disableSubmit: Bool {
            loading || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        func submit() async throws {
            guard let gitHubAPI = gitHubAPI else { return }

            try await withLoading(completion: {
                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = .prettyPrinted
                let additionalFeedbackDataJSON = try jsonEncoder.encode(configuration.additionalFeedbackData)
                let additionalFeedbackDataJSONString = String(data: additionalFeedbackDataJSON, encoding: .utf8) ?? "{}"

                let descriptionWithAdditionalFeedback = """
                # User Feedback

                \(description)

                # Additional Data

                ```json
                \(additionalFeedbackDataJSONString)
                ```
                """

                let result = await gitHubAPI.repos.createIssue(
                    username: configuration.gitHubUsername,
                    repoName: configuration.repoName,
                    title: title,
                    description: descriptionWithAdditionalFeedback,
                    assignee: configuration.gitHubUsername,
                    labels: configuration.additionalIssueLabels + style.labels
                )
                switch result {
                case let .failure(failure):
                    switch failure {
                    case let .parsingError(error: error):
                        #if DEBUG
                        print("parsing error after creating issue; error='\(error)'")
                        #else
                        break
                        #endif
                    default:
                        throw failure
                    }
                case .success: break
                }

                await resetValues()
            })
        }

        @MainActor
        private func resetValues() {
            title = ""
            description = ""
        }

        private func withLoading<T>(completion: () async throws -> T) async throws -> T {
            await setLoading(true)

            var maybeResult: T?
            var maybeError: Error?
            do {
                maybeResult = try await completion()
            } catch {
                maybeError = error
            }

            await setLoading(false)

            if let error = maybeError {
                throw error
            }

            return maybeResult!
        }

        @MainActor
        private func setLoading(_ state: Bool) {
            loading = state
        }
    }
}
