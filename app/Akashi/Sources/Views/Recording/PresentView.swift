import SwiftUI

/// The red "show this to the other party / bystanders" screen (画面04).
struct PresentView: View {
    let record: IncidentRecord
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(.white).frame(width: 60, height: 60)
                Text("記録\n中").font(AppFont.headline(11)).foregroundStyle(AppPalette.presentRedDeep).multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            Text("この状況は\n記録されています")
                .font(AppFont.headline(20))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Text("録音・位置情報・時刻を自動保存中\n周囲の方はご確認いただけます")
                .font(AppFont.body(11))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))

            VStack(spacing: 4) {
                presentRow("記録ID", record.recordCode)
                presentRow("開始時刻", record.startedAt.formatted(date: .omitted, time: .standard))
                presentRow("共有予定先", "警察・弁護士")
            }
            .padding(12)
            .background(Color.white.opacity(0.14))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.35), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Spacer()

            Text("目撃者の方はこの画面から連絡先をご入力ください")
                .font(AppFont.body(11, weight: .medium))
                .foregroundStyle(AppPalette.presentRedDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            Button("閉じる") { dismiss() }
                .font(AppFont.body(11))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(24)
        .background(AppPalette.presentRed.ignoresSafeArea())
    }

    private func presentRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(AppFont.body(10.5)).foregroundStyle(.white.opacity(0.75))
            Spacer()
            Text(value).font(AppFont.mono(10.5)).foregroundStyle(.white)
        }
    }
}

#Preview {
    PresentView(record: IncidentRecord(type: .molestation, recordCode: "AK-77291", startedAt: Date()))
}
