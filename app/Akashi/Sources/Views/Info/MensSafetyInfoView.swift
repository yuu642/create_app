import SwiftUI

struct MensSafetyInfoView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    private let items: [(icon: String, tint: Bool, title: String, subtitle: String)] = [
        ("figure.stand", true, "電車内でできる冤罪対策", "つり革・カバンの持ち方、両手の置き方の工夫を紹介"),
        ("checkmark.shield", false, "日常生活でできる自衛のポイント", "職場・日常のやり取りで記録を残す習慣づくり"),
        ("building.columns", true, "相談窓口・当番弁護士の使い方", "一人で抱え込まないための連絡先まとめ")
    ]

    var body: some View {
        let palette = themeManager.currentTheme
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle().fill(palette.blueBg).frame(width: 26, height: 26)
                        Image(systemName: "person.crop.circle").font(.system(size: 12)).foregroundStyle(palette.blueDeep)
                    }
                    Text("男性向け安心対策").font(AppFont.body(13.5, weight: .medium))
                }
                .padding(.bottom, 12)

                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 10) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.tint ? palette.blueBg : palette.mintBg)
                            .frame(width: 64, height: 52)
                            .overlay(Image(systemName: item.icon).foregroundStyle(item.tint ? palette.blueDeep : palette.mintDeep))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title).font(AppFont.body(11.5, weight: .medium))
                            Text(item.subtitle).font(AppFont.body(9)).foregroundStyle(palette.inkSoft)
                        }
                    }
                    .padding(.vertical, 10)
                    Divider().overlay(palette.line)
                }
            }
            .padding(16)
        }
        .background(palette.paper.ignoresSafeArea())
        .navigationTitle("安心対策")
    }
}

#Preview {
    NavigationStack { MensSafetyInfoView() }.environmentObject(ThemeManager())
}
