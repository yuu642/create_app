import SwiftUI

@main
struct AkashiApp: App {
    @StateObject private var recordStore = RecordStore()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var storeService = StoreService()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView(onFinish: { hasCompletedOnboarding = true })
                }
            }
            .environmentObject(recordStore)
            .environmentObject(themeManager)
            .environmentObject(storeService)
            .tint(themeManager.currentTheme.accent)
        }
    }
}
