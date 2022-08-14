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

@available(iOS 15.0, *)
private let logger = Logger(subsystem: "io.kamaal.SettingsUI", category: String(describing: Store.self))

/// ViewModel to handle donations logic
@available(iOS 15.0, *)
final class Store: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var donations: [CustomProduct] = []
    @Published private(set) var isPurchasing = false

    private var purchasingTask: Task<Void, Never>?
    private var products: [Product] = []
    private var purchasedIdentifiersToTimesPurchased: [String: Int] = [:]
    private var updateListenerTask: Task<Void, Never>?

    let storeKitDonations: [StoreKitDonation.ID: StoreKitDonation]

    init<T: StoreKitDonatable>(storeKitDonations: [T]) {
        self.storeKitDonations = storeKitDonations
            .reduce([:]) { result, donation in
                var mutableResult = result
                mutableResult[donation.id] = StoreKitDonation(fromDonation: donation)
                return mutableResult
            }

        self.updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    var hasDonations: Bool {
        !donations.isEmpty
    }

    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments() && (!isLoading || !isPurchasing)
    }

    func purchaseDonation(_ donation: CustomProduct) {
        guard canMakePayments, let foundProduct = products.first(where: { $0.id == donation.id }) else { return }

        purchasingTask?.cancel()

        purchasingTask = Task {
            let result = await verifyAndPurchase(foundProduct)
            let transaction: Transaction?
            switch result {
            case let .failure(failure):
                // - TODO: HANDLE ERROR
                logger
                    .error(
                        "failed to verify or purchase product; description='\(failure.localizedDescription)'; error='\(failure)'"
                    )
                return
            case let .success(success):
                transaction = success
            }
            guard transaction != nil else { return }

            // - TODO: CONFETTI TIME
        }
    }

    func requestProducts() async -> Result<Void, Error> {
        guard !hasDonations, !storeKitDonations.isEmpty else { return .success(()) }

        logger.info("requesting products")

        return await withLoading(completion: {
            let storeKitDonationsIDs = storeKitDonations.map(\.value.id)

            let products: [Product]
            do {
                products = try await Product.products(for: storeKitDonationsIDs)
            } catch {
                logger.error("failed to get products; description='\(error.localizedDescription)'; error='\(error)'")
                return .failure(error)
            }

            let donations: [CustomProduct] = products
                .compactMap { product in
                    let displayName = product.displayName

                    guard !displayName.isEmpty,
                          product.type == .consumable,
                          let donationItem = storeKitDonations[product.id] else { return nil }

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
                .sorted(by: { $0.weight < $1.weight })

            self.products = products
            await setDonations(donations)

            return .success(())
        })
    }

    private func verifyAndPurchase(_ product: Product) async -> Result<Transaction?, Error> {
        await withIsPurchasing(completion: {
            await withLoading(completion: {
                logger.info("purchasing product with id \(product.id)")

                let purchaseResult: Product.PurchaseResult
                do {
                    purchaseResult = try await product.purchase()
                } catch {
                    return .failure(error)
                }

                let verification: VerificationResult<Transaction>
                switch purchaseResult {
                case .pending, .userCancelled: return .success(.none)
                case let .success(success): verification = success
                default: return .success(.none)
                }

                let transaction: Transaction? = checkVerified(verification)
                // - TODO: WILL LATER ON BE AN ACTUAL VALUE OR ERROR
                guard let transaction = transaction else { return .success(.none) }
                await updatePurchasedIdentifiers(transaction)

                await transaction.finish()
                logger.info("successfully purchased product with id \(transaction.productID)")

                return .success(transaction)
            })
        })
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            guard let self = self else { return }

            // Iterate through any transactions which didn't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                let transaction: Transaction? = self.checkVerified(result)
                // - TODO: WILL LATER ON BE AN ACTUAL VALUE OR ERROR
                guard let transaction = transaction else { continue }

                await self.updatePurchasedIdentifiers(transaction)

                await transaction.finish()
            }
        }
    }

    private func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        let productID = transaction.productID
        if transaction.revocationDate == nil {
            // If the App Store has not revoked the transaction, add it to the list of `purchasedIdentifiers`.
            incrementPurchasedIdentifiers(by: 1, toIdentifier: productID)
        } else {
            // If the App Store has revoked this transaction, remove it from the list of `purchasedIdentifiers`.
            incrementPurchasedIdentifiers(by: -1, toIdentifier: productID)
        }
    }

    private func incrementPurchasedIdentifiers(by increment: Int, toIdentifier identifier: String) {
        let value = purchasedIdentifiersToTimesPurchased[identifier] ?? 0
        if increment < 0, value < 1 {
            return
        }
        purchasedIdentifiersToTimesPurchased[identifier] = value + increment
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) -> T? {
        switch result {
        // StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
        // - TODO: ACTUALLY THROW ERROR INSTEAD
        case .unverified: return nil
        // If the transaction is verified, unwrap and return it.
        case let .verified(safe): return safe
        }
    }

    @MainActor
    private func setDonations(_ donations: [CustomProduct]) {
        self.donations = donations
    }

    @MainActor
    private func withIsPurchasing<T>(completion: () async -> T) async -> T {
        isPurchasing = true
        let result = await completion()
        isPurchasing = false
        return result
    }

    @MainActor
    private func withLoading<T>(completion: () async -> T) async -> T {
        isLoading = true
        let result = await completion()
        isLoading = false
        return result
    }
}
