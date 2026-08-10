import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var storeService: StoreService

    var body: some View {
        List {
            Section("見た目") {
                NavigationLink("着せ替え") { ThemePickerView() }
            }
            Section("情報") {
                NavigationLink("男性向け安心対策") { MensSafetyInfoView() }
                NavigationLink("支援の輪") { SupportCirclesView() }
                NavigationLink("開発者を応援する") { SupporterView() }
            }
            Section("購入の復元") {
                Button("購入を復元する") {
                    Task { await storeService.restorePurchases() }
                }
            }
            Section("法的情報") {
                // GitHub Pages (docs/legal) で公開。リポジトリのSettings > Pagesを
                // 有効化してから利用可能になります。利用規約・特定商取引法に基づく
                // 表記は、正式なApp Store公開の準備が整い次第、同様に公開して追記します。
                Link("プライバシーポリシー", destination: URL(string: "https://yuu642.github.io/create_app/legal/privacy_policy.html")!)
            }
            Section {
                Text("バージョン \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0")")
                    .font(AppFont.body(11))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("設定")
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environmentObject(ThemeManager())
        .environmentObject(StoreService())
}
