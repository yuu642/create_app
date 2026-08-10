import SwiftUI
import StoreKit

struct SupporterView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var storeService: StoreService

    var body: some View {
        let palette = themeManager.currentTheme
        ScrollView {
            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(palette.mintBg).frame(width: 52, height: 52)
                    Image(systemName: "heart.fill").foregroundStyle(palette.mintDeep)
                }
                Text("「あかし」を応援する").font(AppFont.headline(15))
                Text("一人の開発者が、必要だと思って作っています。\nよかったら、気持ちだけでも応援してください。")
                    .font(AppFont.body(10)).multilineTextAlignment(.center).foregroundStyle(palette.inkSoft)

                Text("記録・アラーム・対処法ガイド・弁護士への連絡は、これからもずっと無料です。応援は着せ替えやアラームボイスが増える、任意のものです。")
                    .font(AppFont.body(9.5))
                    .padding(11)
                    .background(palette.blueBg)
                    .foregroundStyle(palette.blueDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                ForEach(storeService.products.sorted(by: { $0.price < $1.price })) { product in
                    SupporterTierRow(
                        product: product,
                        isPurchased: storeService.purchasedProductIDs.contains(product.id),
                        recommended: ProductID(rawValue: product.id) == .supporterLunch
                    ) {
                        Task {
                            let success = await storeService.purchase(product)
                            if success, let themeName = ProductID(rawValue: product.id)?.themeName {
                                themeManager.unlock(themeName)
                            }
                        }
                    }
                }

                if storeService.isLoading {
                    ProgressView().padding(.top, 8)
                }
            }
            .padding(16)
        }
        .background(palette.paper.ignoresSafeArea())
        .navigationTitle("応援する")
        .task { await storeService.loadProducts() }
    }
}

private struct SupporterTierRow: View {
    let product: Product
    let isPurchased: Bool
    let recommended: Bool
    let onPurchase: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                if recommended {
                    Text("人気")
                        .font(AppFont.body(7.5, weight: .medium))
                        .padding(.horizontal, 6).padding(.vertical, 1)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                Text(product.displayName).font(AppFont.body(11.5, weight: .medium))
                Text(product.description).font(AppFont.body(8.5)).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onPurchase) {
                Text(isPurchased ? "購入済み" : product.displayPrice)
                    .font(AppFont.body(12.5, weight: .medium))
            }
            .disabled(isPurchased)
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(recommended ? Color.green : Color.gray.opacity(0.25), lineWidth: recommended ? 2 : 0.5)
        )
    }
}

#Preview {
    NavigationStack { SupporterView() }
        .environmentObject(ThemeManager())
        .environmentObject(StoreService())
}
