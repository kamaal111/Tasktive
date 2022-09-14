//
//  DataSource.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 31/08/2022.
//

import Foundation

enum DataSource: Codable, Hashable, CaseIterable {
    case coreData
    case iCloud

    var requiresInternet: Bool {
        switch self {
        case .coreData:
            return false
        case .iCloud:
            return true
        }
    }

    var isSupported: Bool {
        switch self {
        case .coreData:
            return true
        case .iCloud:
            return Features.iCloudSyncing
        }
    }

    var persistanceMethodImageName: String {
        switch self {
        case .coreData:
            return "iphone.and.arrow.forward"
        case .iCloud:
            return "icloud"
        }
    }
}
