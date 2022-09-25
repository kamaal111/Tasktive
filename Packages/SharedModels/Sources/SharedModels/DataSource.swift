//
//  DataSource.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Foundation
import Environment

public enum DataSource: Codable, Hashable, CaseIterable {
    case coreData
    case iCloud

    public var requiresInternet: Bool {
        switch self {
        case .coreData:
            return false
        case .iCloud:
            return true
        }
    }

    public var isSupported: Bool {
        switch self {
        case .coreData:
            return true
        case .iCloud:
            return Environment.Features.iCloudSyncing
        }
    }

    public var persistanceMethodImageName: String {
        switch self {
        case .coreData:
            return "iphone.and.arrow.forward"
        case .iCloud:
            return "icloud"
        }
    }
}
