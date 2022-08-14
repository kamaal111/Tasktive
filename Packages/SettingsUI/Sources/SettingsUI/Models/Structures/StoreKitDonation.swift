//
//  StoreKitDonation.swift
//
//
//  Created by Kamaal M Farah on 13/08/2022.
//

import Foundation

struct StoreKitDonation: Hashable, Identifiable, StoreKitDonatable {
    var id: String
    var emoji: String
    var weight: Int

    init(id: String, emoji: String, weight: Int) {
        self.id = id
        self.emoji = emoji
        self.weight = weight
    }

    init(fromDonation donatable: some StoreKitDonatable) {
        self.init(id: donatable.id, emoji: donatable.emoji, weight: donatable.weight)
    }
}
