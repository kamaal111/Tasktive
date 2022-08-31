//
//  Features.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 31/08/2022.
//

import Foundation

enum Features {
    #if DEBUG
    static let iCloudSyncing = true
    #else
    static let iCloudSyncing = false
    #endif
}
