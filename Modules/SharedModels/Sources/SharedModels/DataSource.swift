//
//  DataSource.swift
//
//
//  Created by Kamaal M Farah on 25/09/2022.
//

import Foundation
import Environment
import TasktiveLocale

/// Data source representation that tells where a certain object comes from.
public enum DataSource: Codable, Hashable, CaseIterable {
    /// From iCloud store.
    case iCloud
    /// From CoreData store.
    case coreData

    /// If the parent object requires internet for the content to be fetched.
    public var requiresInternet: Bool {
        switch self {
        case .coreData:
            return false
        case .iCloud:
            return true
        }
    }

    /// If the object is supported to be fetched and modified.
    public var isSupported: Bool {
        switch self {
        case .coreData:
            return true
        case .iCloud:
            return Environment.Features.iCloudSyncing
        }
    }

    /// Image system image name of a corresponding SFSymbol.
    public var persistanceMethodImageName: String {
        switch self {
        case .coreData:
            return "arrow.turn.up.forward.iphone"
        case .iCloud:
            return "icloud"
        }
    }

    public var label: String {
        switch self {
        case .iCloud:
            return TasktiveLocale.getText(.ICLOUD)
        case .coreData:
            return TasktiveLocale.getText(.LOCALLY)
        }
    }
}
