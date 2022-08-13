//
//  StoreKitDonation.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 13/08/2022.
//

import Foundation
import SettingsUI

struct StoreKitDonation: Hashable, Identifiable, StoreKitDonatable {
    var id: String
    var emoji: String
    var weight: Int
}
