//
//  TokensHolder.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 06/08/2022.
//

import Logster
import Foundation

private let logger = Logster(from: TokensHolder.self)

final class TokensHolder {
    var tokens: Tokens?

    private init() {
        guard let pathToTokens = Bundle.main.path(forResource: "Tokens", ofType: "json") else { return }

        let urlToTokens = URL(fileURLWithPath: pathToTokens)
        let tokensData: Data
        do {
            tokensData = try Data(contentsOf: urlToTokens)
        } catch {
            logger.error(label: "failed while getting tokens data", error: error)
            return
        }

        let tokens: Tokens
        do {
            tokens = try JSONDecoder().decode(Tokens.self, from: tokensData)
        } catch {
            logger.error(label: "failed while decoding tokens data", error: error)
            return
        }

        self.tokens = tokens
    }

    static let shared = TokensHolder()
}

struct Tokens: Codable {
    let gitHubToken: String?

    enum CodingKeys: String, CodingKey {
        case gitHubToken = "github_token"
    }
}
