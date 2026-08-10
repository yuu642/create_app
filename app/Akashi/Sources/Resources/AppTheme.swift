import SwiftUI

/// Color roles mirrored from the HTML design prototype (akashi_app_prototype_v2.html).
struct AppPalette {
    let name: String
    let displayName: String
    let paper: Color
    let paperDeep: Color
    let ink: Color
    let inkSoft: Color
    let line: Color
    let blue: Color
    let blueDeep: Color
    let blueBg: Color
    let mint: Color
    let mintDeep: Color
    let mintBg: Color
    let accent: Color
    let isFree: Bool

    static let launch = AppPalette(
        name: "launch",
        displayName: "はじまりの色",
        paper: Color(hex: 0xF7FAFA),
        paperDeep: Color(hex: 0xEEF3F3),
        ink: Color(hex: 0x1E2B38),
        inkSoft: Color(hex: 0x647485),
        line: Color(hex: 0xDCE6E6),
        blue: Color(hex: 0x2D84BF),
        blueDeep: Color(hex: 0x1B4E70),
        blueBg: Color(hex: 0xE7F3FA),
        mint: Color(hex: 0x2FA98B),
        mintDeep: Color(hex: 0x1C6B55),
        mintBg: Color(hex: 0xE2F6EF),
        accent: Color(hex: 0x2D84BF),
        isFree: true
    )

    static let sakura = AppPalette(
        name: "sakura",
        displayName: "さくら",
        paper: Color(hex: 0xFFFBFC),
        paperDeep: Color(hex: 0xFBEFF2),
        ink: Color(hex: 0x1E2B38),
        inkSoft: Color(hex: 0x647485),
        line: Color(hex: 0xF4D8DE),
        blue: Color(hex: 0xE9A8B8),
        blueDeep: Color(hex: 0xB86B7E),
        blueBg: Color(hex: 0xFBEFF2),
        mint: Color(hex: 0x2FA98B),
        mintDeep: Color(hex: 0x1C6B55),
        mintBg: Color(hex: 0xE2F6EF),
        accent: Color(hex: 0xE9A8B8),
        isFree: false
    )

    static let night = AppPalette(
        name: "night",
        displayName: "夜のしずく",
        paper: Color(hex: 0xF2F5F7),
        paperDeep: Color(hex: 0xE3E9ED),
        ink: Color(hex: 0x1E2B38),
        inkSoft: Color(hex: 0x647485),
        line: Color(hex: 0x5D7A8F),
        blue: Color(hex: 0x3E5A73),
        blueDeep: Color(hex: 0x1E2B38),
        blueBg: Color(hex: 0xE3E9ED),
        mint: Color(hex: 0x2FA98B),
        mintDeep: Color(hex: 0x1C6B55),
        mintBg: Color(hex: 0xE2F6EF),
        accent: Color(hex: 0x3E5A73),
        isFree: false
    )

    static let dawn = AppPalette(
        name: "dawn",
        displayName: "朝焼け",
        paper: Color(hex: 0xFFFCF8),
        paperDeep: Color(hex: 0xEFE0C8),
        ink: Color(hex: 0x1E2B38),
        inkSoft: Color(hex: 0x647485),
        line: Color(hex: 0xEFE0C8),
        blue: Color(hex: 0xE7B36A),
        blueDeep: Color(hex: 0xB8823A),
        blueBg: Color(hex: 0xFBF1DE),
        mint: Color(hex: 0x2FA98B),
        mintDeep: Color(hex: 0x1C6B55),
        mintBg: Color(hex: 0xE2F6EF),
        accent: Color(hex: 0xE7B36A),
        isFree: false
    )

    static let all: [AppPalette] = [.launch, .sakura, .night, .dawn]

    static let presentRed = Color(hex: 0xC4342D)
    static let presentRedDeep = Color(hex: 0x7A1F1A)
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    @Published private(set) var currentTheme: AppPalette
    @Published private(set) var unlockedThemeNames: Set<String>

    private let selectedKey = "selectedThemeName"
    private let unlockedKey = "unlockedThemeNames"

    init() {
        let defaults = UserDefaults.standard
        let unlocked = Set(defaults.stringArray(forKey: unlockedKey) ?? [AppPalette.launch.name])
        self.unlockedThemeNames = unlocked
        let selectedName = defaults.string(forKey: selectedKey) ?? AppPalette.launch.name
        self.currentTheme = AppPalette.all.first(where: { $0.name == selectedName }) ?? .launch
    }

    func isUnlocked(_ theme: AppPalette) -> Bool {
        theme.isFree || unlockedThemeNames.contains(theme.name)
    }

    func select(_ theme: AppPalette) {
        guard isUnlocked(theme) else { return }
        currentTheme = theme
        UserDefaults.standard.set(theme.name, forKey: selectedKey)
    }

    func unlock(_ themeName: String) {
        unlockedThemeNames.insert(themeName)
        UserDefaults.standard.set(Array(unlockedThemeNames), forKey: unlockedKey)
    }
}
