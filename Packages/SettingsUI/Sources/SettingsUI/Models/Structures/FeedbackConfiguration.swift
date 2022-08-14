//
//  FeedbackConfiguration.swift
//
//
//  Created by Kamaal M Farah on 12/08/2022.
//

import Foundation

/// Configuration for the feedback row in the settings screen.
public struct FeedbackConfiguration {
    /// This token will be used to create issues in GitHub.
    public let gitHubToken: String
    /// The username or organization name of the repo where we will create the issue on.
    public let gitHubUsername: String
    /// The repo name where we create the issue on.
    public let repoName: String
    /// Some extra data to send with the issue.
    public let additionalFeedbackData: Encodable
    /// Extra labels on the issue that will be created.
    public let additionalIssueLabels: [String]

    /// Main initializer for FeedbackConfiguration.
    /// - Parameters:
    ///   - gitHubToken: This token will be used to create issues in GitHub.
    ///   - gitHubUsername: The username or organization name of the repo where we will create the issue on.
    ///   - repoName: The repo name where we create the issue on.
    ///   - additionalFeedbackData: Some extra data to send with the issue.
    ///   - additionalIssueLabels: Extra labels on the issue that will be created.
    public init(
        gitHubToken: String,
        gitHubUsername: String,
        repoName: String,
        additionalFeedbackData: Encodable,
        additionalIssueLabels: [String] = []
    ) {
        self.gitHubToken = gitHubToken
        self.gitHubUsername = gitHubUsername
        self.repoName = repoName
        self.additionalFeedbackData = additionalFeedbackData
        self.additionalIssueLabels = additionalIssueLabels
    }
}
