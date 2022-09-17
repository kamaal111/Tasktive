//
//  UserData.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 16/09/2022.
//

import Foundation

final class UserData: ObservableObject {
    @Published var iCloudSyncingIsEnabled: Bool {
        didSet {
            iCloudSyncingIsEnabledDidSet()
        }
    }

    init() {
        self.iCloudSyncingIsEnabled = UserDefaults.iCloudSyncingIsEnabled ?? false
    }

    private func iCloudSyncingIsEnabledDidSet() {
        UserDefaults.iCloudSyncingIsEnabled = iCloudSyncingIsEnabled
    }
}
