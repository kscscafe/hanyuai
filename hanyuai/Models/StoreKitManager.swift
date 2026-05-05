import Foundation
import Combine
import StoreKit

enum IAPProduct {
    static let ticket10 = "jp.co.officees.hanyuai.ticket10"
    static let premiumMonthly = "jp.co.officees.hanyuai.premium.monthly"
}

enum StoreError: Error {
    case failedVerification
}

@MainActor
final class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPremium: Bool = false

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // 商品取得
    func loadProducts() async {
        do {
            products = try await Product.products(for: [
                IAPProduct.ticket10,
                IAPProduct.premiumMonthly
            ])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // 購入処理
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    // 購入済み確認
    func updatePurchasedProducts() async {
        var purchased = Set<String>()
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
        isPremium = purchased.contains(IAPProduct.premiumMonthly)
    }

    // リストア
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }

    // トランザクション監視
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? await self.checkVerified(result) {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
