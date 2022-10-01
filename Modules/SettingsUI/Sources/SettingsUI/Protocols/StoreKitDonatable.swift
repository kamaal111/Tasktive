//
//  StoreKitDonatable.swift
//
//
//  Created by Kamaal M Farah on 13/08/2022.
//

import Foundation

public protocol StoreKitDonatable: Hashable, Identifiable {
    var id: String { get set }
    var emoji: String { get set }
    var weight: Int { get set }
}
