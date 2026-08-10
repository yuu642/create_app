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
                // TODO: GitHub Pages公開後、実際のURLに差し替える
                Link("プライバシーポリシー", destination: URL(string: "https://example.com/akashi/privacy")!)
                Link("利用規約", destination: URL(string: "https://example.com/akashi/terms")!)
                Link("特定商取引法に基づく表記", destination: URL(string: "https://example.com/akashi/tokushoho")!)
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
