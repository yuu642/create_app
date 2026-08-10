import SwiftUI

struct GuideView: View {
    var scrollToHotline: Bool = false
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        let palette = themeManager.currentTheme
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("疑われたら、まずこの順番で").font(AppFont.headline(15))
                        Text("認めても否定しても、記録と冷静さを優先する").font(AppFont.body(10)).foregroundStyle(palette.inkSoft)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("意図的な虚偽の申告は、重大な犯罪です").font(AppFont.body(11.5, weight: .medium))
                        Text("人を陥れる目的で嘘の告訴・告発をした場合、「虚偽告訴等罪」に問われます。罰金刑はなく、拘禁刑のみが科される重い犯罪です。記録を残すことは、あなたの潔白を守るための正当な行為です。")
                            .font(AppFont.body(10)).opacity(0.92).lineSpacing(3)
                        Text("刑法172条・3か月以上10年以下の拘禁刑").font(AppFont.mono(9)).opacity(0.75)
                    }
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(palette.blueDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    guideSection(
                        title: "痴漢を疑われた場合",
                        chipColor: palette.blue,
                        dos: [("記録を開始し、駅員・警察には同行する", "任意同行と理解しつつ、その場で拒否はしない")],
                        donts: [("その場で示談・署名に応じない", "弁護士に相談してから対応する")]
                    )

                    guideSection(
                        title: "盗撮を疑われた場合",
                        chipColor: palette.mint,
                        dos: [("画面録画とスマホ内の記録を提示する", "カメラ未使用の証拠として活用する")],
                        donts: [("スマホを渡さない・自分で消去しない", "確認は警察立会いの下でのみ応じる")]
                    )

                    hotlineCard(palette: palette)
                        .id("hotline")

                    Text("※本アプリの案内は一般的な情報であり、個別の法律相談に代わるものではありません。具体的な事案は弁護士等の専門家にご相談ください。")
                        .font(AppFont.body(9.5))
                        .foregroundStyle(palette.inkSoft)
                }
                .padding(16)
            }
            .background(palette.paper.ignoresSafeArea())
            .navigationTitle("対処法ガイド")
            .onAppear {
                if scrollToHotline {
                    withAnimation { proxy.scrollTo("hotline", anchor: .top) }
                }
            }
        }
    }

    private func guideSection(title: String, chipColor: Color, dos: [(String, String)], donts: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Circle().fill(chipColor).frame(width: 8, height: 8)
                Text(title).font(AppFont.body(10.5, weight: .medium))
            }
            ForEach(dos, id: \.0) { step in
                stepRow(number: "01", title: step.0, subtitle: step.1, isDont: false)
            }
            ForEach(donts, id: \.0) { step in
                stepRow(number: "✕", title: step.0, subtitle: step.1, isDont: true)
            }
        }
    }

    private func stepRow(number: String, title: String, subtitle: String, isDont: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(AppFont.mono(9.5))
                .foregroundStyle(isDont ? themeManager.currentTheme.inkSoft : themeManager.currentTheme.blueDeep)
                .frame(minWidth: 14)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(AppFont.body(10.5, weight: .medium))
                Text(subtitle).font(AppFont.body(9)).foregroundStyle(themeManager.currentTheme.inkSoft)
            }
        }
    }

    private func hotlineCard(palette: AppPalette) -> some View {
        // TODO: 実際に連携する弁護士相談窓口(当番弁護士制度・法テラス等)の電話番号を確定させ、ここに設定してください。
        Link(destination: URL(string: "tel:0000000000")!) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("冤罪弁護士ホットライン").font(AppFont.body(11, weight: .medium))
                    Text("当番弁護士制度にも接続").font(AppFont.body(9)).opacity(0.85)
                }
                Spacer()
                Image(systemName: "arrow.right")
            }
            .foregroundStyle(.white)
            .padding(12)
            .background(palette.blueDeep)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

#Preview {
    NavigationStack { GuideView() }.environmentObject(ThemeManager())
}
