//
//  TokensHolder.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 06/08/2022.
//

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
            let message = "failed while getting tokens data"
            let description = "localizedDescription='\(error.localizedDescription)'"
            let errorLabel = "error='\(error)'"
            let errorToLog = [message, description, errorLabel].joined(separator: "; ")
            logger.error(errorToLog)
            return
        }

        let tokens: Tokens
        do {
            tokens = try JSONDecoder().decode(Tokens.self, from: tokensData)
        } catch {
            let message = "failed while decoding tokens data"
            let description = "localizedDescription='\(error.localizedDescription)'"
            let errorLabel = "error='\(error)'"
            let errorToLog = [message, description, errorLabel].joined(separator: "; ")
            logger.error(errorToLog)
            return
        }

        self.tokens = tokens
    }

    static let shared = TokensHolder()
}

struct Tokens: Codable {
    let gitHubToken: String?
}
