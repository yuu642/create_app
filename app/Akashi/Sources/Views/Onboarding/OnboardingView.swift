import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        let palette = themeManager.currentTheme
        VStack(spacing: 18) {
            Spacer(minLength: 12)

            ZStack {
                Circle().fill(palette.blueBg).frame(width: 64, height: 64)
                Image(systemName: "shield.checkerboard")
                    .foregroundStyle(palette.blueDeep)
                    .font(.system(size: 26))
            }

            Text("記録を残すことは、\n正当な自衛です")
                .font(AppFont.headline(21))
                .multilineTextAlignment(.center)
                .foregroundStyle(palette.ink)

            VStack(alignment: .leading, spacing: 6) {
                Text("刑法172条 虚偽告訴等罪")
                    .font(AppFont.body(11))
                    .opacity(0.75)
                Text("3か月〜10年の拘禁刑")
                    .font(AppFont.mono(20))
                Text("人を陥れる目的で嘘の告訴をした場合に問われる、罰金刑のない重い犯罪です。あなたが証拠を残すことに、後ろめたさはいりません。")
                    .font(AppFont.body(12.5))
                    .opacity(0.92)
                    .lineSpacing(4)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(palette.blueDeep)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text("「あかし」は、疑われた瞬間の記録・対処法・弁護士への連絡を無料でサポートするアプリです。")
                .font(AppFont.body(12.5))
                .foregroundStyle(palette.mintDeep)
                .lineSpacing(4)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(palette.mintBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Spacer()

            Button(action: onFinish) {
                Text("はじめる")
                    .font(AppFont.body(15, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(palette.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(24)
        .background(palette.paperDeep.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView(onFinish: {}).environmentObject(ThemeManager())
}
