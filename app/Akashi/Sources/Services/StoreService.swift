import Foundation
import StoreKit

enum ProductID: String, CaseIterable {
    case supporterCoffee = "com.akashi.app.supporter.coffee"
    case supporterLunch = "com.akashi.app.supporter.lunch"
    case supporterFull = "com.akashi.app.supporter.full"
    case themeSakura = "com.akashi.app.theme.sakura"
    case themeNight = "com.akashi.app.theme.night"
    case themeDawn = "com.akashi.app.theme.dawn"

    var themeName: String? {
        switch self {
        case .themeSakura: return AppPalette.sakura.name
        case .themeNight: return AppPalette.night.name
        case .themeDawn: return AppPalette.dawn.name
        default: return nil
        }
    }
}

/// Every purchasable item in "あかし" is a cosmetic/optional extra (supporter
/// badge, themes, alarm voices). Core safety features (recording, alarm,
/// guide, lawyer contact) never require purchase or entitlement checks.
@MainActor
final class StoreService: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var lastErrorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            await self?.observeTransactionUpdates()
        }
        Task { await loadProducts() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: ProductID.allCases.map { $0.rawValue })
            await refreshEntitlements()
        } catch {
            lastErrorMessage = "商品情報の取得に失敗しました: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                    return true
                }
                return false
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastErrorMessage = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
    }

    private func observeTransactionUpdates() async {
        for await update in Transaction.updates {
            if case .verified(let transaction) = update {
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            }
        }
    }
}
