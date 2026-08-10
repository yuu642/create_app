import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var storeService: StoreService
    @State private var purchasingTheme: AppPalette?
    @State private var showSupporterScreen = false

    var body: some View {
        let palette = themeManager.currentTheme
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(AppPalette.all, id: \.name) { theme in
                    Button {
                        handleTap(theme)
                    } label: {
                        ThemeCard(
                            theme: theme,
                            isSelected: themeManager.currentTheme.name == theme.name,
                            isUnlocked: themeManager.isUnlocked(theme)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)

            Text("記録・アラームなど安全に関わる機能は、どのテーマでも同じように使えます")
                .font(AppFont.body(9))
                .foregroundStyle(palette.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .background(palette.paper.ignoresSafeArea())
        .navigationTitle("着せ替え")
        .alert("応援して解放しますか？", isPresented: Binding(
            get: { purchasingTheme != nil },
            set: { if !$0 { purchasingTheme = nil } }
        )) {
            Button("キャンセル", role: .cancel) { purchasingTheme = nil }
            Button("応援画面を開く") {
                purchasingTheme = nil
                showSupporterScreen = true
            }
        }
        .navigationDestination(isPresented: $showSupporterScreen) {
            SupporterView()
        }
    }

    private func handleTap(_ theme: AppPalette) {
        if themeManager.isUnlocked(theme) {
            themeManager.select(theme)
        } else {
            purchasingTheme = theme
        }
    }
}

private struct ThemeCard: View {
    let theme: AppPalette
    let isSelected: Bool
    let isUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 0) {
                    Color.white
                    theme.blue
                    theme.mint
                }
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                if !isUnlocked {
                    ZStack {
                        Circle().fill(.white.opacity(0.92)).frame(width: 20, height: 20)
                        Image(systemName: "lock.fill").font(.system(size: 9))
                    }
                    .padding(6)
                }
            }
            Text(theme.displayName).font(AppFont.body(10.5, weight: .medium))
            Text(isUnlocked ? (isSelected ? "適用中" : "利用可能") : "応援で解放")
                .font(AppFont.body(8.5)).foregroundStyle(.secondary)
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? theme.blue : Color.gray.opacity(0.25), lineWidth: isSelected ? 2 : 0.5)
        )
    }
}

#Preview {
    NavigationStack { ThemePickerView() }
        .environmentObject(ThemeManager())
        .environmentObject(StoreService())
}
