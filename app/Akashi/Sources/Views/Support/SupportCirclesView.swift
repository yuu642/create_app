import SwiftUI

/// Neutral summary of external citizen activities (e.g. petitions, crowdfunding).
/// Does not endorse any specific organization — see the disclaimer at the bottom.
struct SupportCirclesView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    private let cards: [(chip: String, blue: Bool, title: String, body: String)] = [
        ("オンライン署名", true, "男性専用車両の導入を求める署名", "Change.org 等で継続的に署名が集められている活動があります"),
        ("クラウドファンディング", false, "貸切車両イベントの開催支援", "NPO法人などがREADYFOR等で資金を募り、イベントを実施した実績があります"),
        ("寄付・エール", true, "活動継続のための寄付・応援", "署名サイトを通じた寄付機能で、発起人を継続的に支援できる仕組みもあります")
    ]

    var body: some View {
        let palette = themeManager.currentTheme
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("広がる取り組みを知る").font(AppFont.headline(15))
                Text("男性専用車両の導入などを求めて、全国で行われている市民活動の情報をまとめています")
                    .font(AppFont.body(9.5)).foregroundStyle(palette.inkSoft)

                ForEach(Array(cards.enumerated()), id: \.offset) { _, card in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(card.chip)
                            .font(AppFont.body(8.5, weight: .medium))
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(card.blue ? palette.blueBg : palette.mintBg)
                            .foregroundStyle(card.blue ? palette.blueDeep : palette.mintDeep)
                            .clipShape(Capsule())
                        Text(card.title).font(AppFont.body(11.5, weight: .medium))
                        Text(card.body).font(AppFont.body(9.5)).foregroundStyle(palette.inkSoft)
                    }
                    .padding(11)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(palette.line, lineWidth: 0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Text("本画面は外部の市民活動・団体の情報をまとめて紹介するものです。特定の団体・活動を公式に支持・保証するものではなく、リンク先の詳細は各運営元をご確認ください。")
                    .font(AppFont.body(8.5))
                    .foregroundStyle(palette.inkSoft)
                    .padding(.top, 6)
            }
            .padding(16)
        }
        .background(palette.paper.ignoresSafeArea())
        .navigationTitle("支援の輪")
    }
}

#Preview {
    NavigationStack { SupportCirclesView() }.environmentObject(ThemeManager())
}
