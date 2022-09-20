//
//  Store.swift
//
//
//  Created by Kamaal M Farah on 12/08/2022.
//

import Logster
import StoreAPI
import StoreKit
import Foundation

private let logger = Logster(from: Store.self)

extension Store {
    enum Errors: Error {
        case failedVerification
        case getProducts
        case purchaseError(causeError: Error?)
        case noTransactionMade
    }
}

/// ViewModel to handle donations logic.
final class Store: NSObject, ObservableObject {
    /// Loading state. View should indicate there is a proccess loading.
    @Published private(set) var isLoading = false
    /// Requested donations from StoreKit.
    @Published private(set) var donations: [CustomProduct] = []
    /// Purchasing state. View should indicate user is currently purchasing.
    @Published private(set) var isPurchasing = false

    private var purchasingTask: Task<Void, Never>?
    private var products: [Product] = []
    private var purchasedIdentifiersToTimesPurchased: [String: Int] = [:]
    private var updateListenerTask: Task<Void, Never>?

    var storeKitDonations: [StoreKitDonation.ID: StoreKitDonation] = [:]

    override init() { }

    init<T: StoreKitDonatable>(storeKitDonations: [T]) {
        self.storeKitDonations = storeKitDonations
            .reduce([:]) { result, donation in
                var mutableResult = result
                mutableResult[donation.id] = StoreKitDonation(fromDonation: donation)
                return mutableResult
            }

        super.init()

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

    func purchaseDonation(_ donation: CustomProduct, completion: @escaping (Result<Transaction, Errors>) -> Void) {
        guard canMakePayments, let foundProduct = products.first(where: { $0.id == donation.id }) else { return }

        purchasingTask?.cancel()

        purchasingTask = Task {
            let result = await verifyAndPurchase(foundProduct)
            let transaction: Transaction?
            switch result {
            case let .failure(failure):
                let message = [
                    "failed to verify or purchase product",
                    "description='\(failure.localizedDescription)'",
                    "error='\(failure)'",
                ].joined(separator: ";")
                logger.error("\(message)")
                completion(.failure(failure))
                return
            case let .success(success):
                transaction = success
            }
            guard let transaction = transaction else {
                completion(.failure(.noTransactionMade))
                return
            }

            completion(.success(transaction))
        }
    }

    func requestProducts() async -> Result<Void, Errors> {
        guard !hasDonations, !storeKitDonations.isEmpty else { return .success(()) }

        logger.info("requesting products")

        return await withLoading(completion: {
            let storeKitDonationsIDs = storeKitDonations.map(\.value.id)

            let products: [Product]
            do {
                products = try await Product.products(for: storeKitDonationsIDs)
            } catch {
                let message = "failed to get products; description='\(error.localizedDescription)'; error='\(error)'"
                logger.error("\(message)")
                return .failure(.getProducts)
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

    private func verifyAndPurchase(_ product: Product) async -> Result<Transaction?, Errors> {
        await withIsPurchasing(completion: {
            await withLoading(completion: {
                logger.info("purchasing product with id \(product.id)")

                let purchaseResult: Product.PurchaseResult
                do {
                    purchaseResult = try await product.purchase()
                } catch {
                    let message = [
                        "failed to purchase product",
                        "description='\(error.localizedDescription)'",
                        "error='\(error)'",
                    ].joined(separator: ";")
                    logger.error("\(message)")
                    return .failure(.purchaseError(causeError: error))
                }

                let verification: VerificationResult<Transaction>
                switch purchaseResult {
                case .pending, .userCancelled: return .success(.none)
                case let .success(success): verification = success
                default: return .success(.none)
                }

                let transaction: Transaction
                switch checkVerified(verification) {
                case let .failure(failure):
                    return .failure(failure)
                case let .success(success):
                    transaction = success
                }

                await updatePurchasedIdentifiers(transaction)

                await transaction.finish()
                logger.info("successfully purchased product with id \(transaction.productID)")

                return .success(transaction)
            })
        })
    }

    /// Update transactions regularly on a detached task for whenever the user makes a transaction outside of the app
    /// - Returns: a Task result that does not return anything and does not fail
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            guard let self = self else { return }

            // Iterate through any transactions which didn't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                let transaction: Transaction
                switch self.checkVerified(result) {
                case let .failure(failure):
                    let message = "failed to verify transaction; error='\(failure)'"
                    logger.error("\(message)")
                    continue
                case let .success(success):
                    transaction = success
                }

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

    private func checkVerified<T>(_ result: VerificationResult<T>) -> Result<T, Errors> {
        switch result {
        // StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
        case .unverified: return .failure(.failedVerification)
        // If the transaction is verified, unwrap and return it.
        case let .verified(safe): return .success(safe)
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

@available(iOS 15.0, *)
extension Store: SKPaymentTransactionObserver {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let purchasedOrRestoredOriginalTransactionID = transactions
            .filter { $0.transactionState == .purchased || $0.transactionState == .restored }
            .compactMap { $0.original?.transactionIdentifier }
        logger.info("purchasedOrRestoredOriginalTransactionID='\(purchasedOrRestoredOriginalTransactionID)'")
    }

    func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        let message = [
            "failed to restore transactions",
            "description='\(error.localizedDescription)'",
            "error='\(error)'",
        ]
        logger.error("\(message)")
    }
}
