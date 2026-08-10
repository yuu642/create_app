import SwiftUI

/// Font roles mirrored from the prototype: Shippori Mincho for headlines,
/// Noto Sans JP (system default covers this on-device) for body text, and a
/// monospaced face for timestamps / record codes.
enum AppFont {
    static func headline(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }

    static func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

struct RoundedCard<Content: View>: View {
    var background: Color
    var content: Content

    init(background: Color, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
