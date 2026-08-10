import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("ホーム", systemImage: "house") }

            NavigationStack { RecordsListView() }
                .tabItem { Label("記録", systemImage: "list.bullet.rectangle") }

            NavigationStack { GuideView() }
                .tabItem { Label("ガイド", systemImage: "book") }

            NavigationStack { SettingsView() }
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
        .tint(themeManager.currentTheme.blueDeep)
    }
}
