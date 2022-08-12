//
//  FeedbackConfiguration.swift
//
//
//  Created by Kamaal M Farah on 12/08/2022.
//

import Foundation

public struct FeedbackConfiguration {
    public let gitHubToken: String
    public let gitHubUsername: String
    public let repoName: String
    public let additionalFeedbackData: Encodable
    public let additionalIssueLabels: [String]

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
