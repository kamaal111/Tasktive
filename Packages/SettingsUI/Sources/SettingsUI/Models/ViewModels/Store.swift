//
//  Store.swift
//
//
//  Created by Kamaal M Farah on 12/08/2022.
//

import os.log
import StoreAPI
import StoreKit
import Foundation

private let logger = Logger(subsystem: "io.kamaal.SettingsUI", category: String(describing: Store.self))

final class Store: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var donations: [CustomProduct] = []
    @Published private(set) var isPurchasing = false

    let storeKitDonations: [StoreKitDonation]

    init<T: StoreKitDonatable>(storeKitDonations: [T]) {
        self.storeKitDonations = storeKitDonations
            .map(StoreKitDonation.init(_:))
    }

    var hasDonations: Bool {
        !donations.isEmpty
    }

    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments() && !isLoading
    }

    func requestProducts() async -> Result<Void, Error> {
        guard !hasDonations, !storeKitDonations.isEmpty else { return .success(()) }

        logger.info("requesting products")

        return await withLoading(completion: {
            let storeKitDonationsIDs = storeKitDonations.map(\.id)

            let products: [Product]
            do {
                products = try await Product.products(for: storeKitDonationsIDs)
            } catch {
                logger.error("failed to get products; description='\(error.localizedDescription)'; error='\(error)'")
                return .failure(error)
            }

            donations = products
                .compactMap { product in
                    let displayName = product.displayName

                    guard !displayName.isEmpty,
                          product.type == .consumable,
                          let donationItem = storeKitDonations.first(where: { $0.id == product.id }) else { return nil }

                    return CustomProduct(
                        id: product.id,
                        emoji: donationItem.emoji,
                        weight: donationItem.weight,
                        displayName: displayName,
                        displayPrice: product.displayPrice,
                        price: product.price,
                        description: product.description
                    )
                }
                .sorted(by: { $0.price < $1.price })

            return .success(())
        })
    }

    @MainActor
    private func withLoading<T>(completion: () async -> T) async -> T {
        isLoading = true
        let result = await completion()
        isLoading = false
        return result
    }
}