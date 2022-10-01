//
//  NotificationsClient.swift
//  Backend
//
//  Created by Kamaal M Farah on 29/09/2022.
//

import Skypiea
import Foundation

public class NotificationsClient {
    private let skypiea: Skypiea

    public init(preview: Bool) {
        if !preview {
            self.skypiea = .shared
        } else {
            self.skypiea = .preview
        }
    }

    public func subscribeToAll() async throws {
        try await skypiea.subscripeToAll()
    }
}
