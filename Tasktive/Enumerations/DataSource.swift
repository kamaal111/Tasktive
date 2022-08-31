//
//  DataSource.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 31/08/2022.
//

import Foundation

enum DataSource: Codable, Hashable, CaseIterable {
    case coreData
//    case iCloud

    var persistanceMethodImageName: String {
        switch self {
        case .coreData:
            return "iphone.and.arrow.forward"
//        case .iCloud:
//            return "icloud"
        }
    }
}
