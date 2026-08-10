import SwiftUI
import UIKit

struct RecordsListView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var recordStore: RecordStore
    @State private var shareItem: URL?

    var body: some View {
        let palette = themeManager.currentTheme
        ScrollView {
            VStack(spacing: 9) {
                if recordStore.records.isEmpty {
                    Text("まだ記録がありません")
                        .font(AppFont.body(12))
                        .foregroundStyle(palette.inkSoft)
                        .padding(.top, 40)
                } else {
                    ForEach(recordStore.records) { record in
                        RecordRow(record: record, palette: palette) {
                            shareItem = recordStore.exportPackage(for: record)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(palette.paper.ignoresSafeArea())
        .navigationTitle("記録一覧 (全\(recordStore.records.count)件)")
        .sheet(item: Binding(
            get: { shareItem.map { IdentifiableURL(url: $0) } },
            set: { shareItem = $0?.url }
        )) { wrapped in
            ShareSheet(activityItems: [wrapped.url])
        }
    }
}

private struct RecordRow: View {
    let record: IncidentRecord
    let palette: AppPalette
    let onExport: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().stroke(palette.mint, lineWidth: 1.4).frame(width: 34, height: 34)
                Text("証拠\n済").font(AppFont.headline(9)).foregroundStyle(palette.mintDeep).multilineTextAlignment(.center)
            }
            .rotationEffect(.degrees(-6))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.startedAt.formatted(date: .numeric, time: .shortened))
                    .font(AppFont.mono(9.5)).foregroundStyle(palette.inkSoft)
                Text("\(record.durationLabel)・\(record.locationDescription ?? "位置情報なし")")
                    .font(AppFont.body(11, weight: .medium))
                Text(evidenceSummary)
                    .font(AppFont.body(9)).foregroundStyle(palette.inkSoft)
                Text(record.type.shortLabel + "モード")
                    .font(AppFont.body(8, weight: .medium))
                    .padding(.horizontal, 7).padding(.vertical, 1)
                    .background(record.type == .molestation ? palette.blueBg : palette.mintBg)
                    .foregroundStyle(record.type == .molestation ? palette.blueDeep : palette.mintDeep)
                    .clipShape(Capsule())
            }
            Spacer()
            Button(action: onExport) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .padding(11)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(palette.line, lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var evidenceSummary: String {
        var parts: [String] = []
        if record.audioFileName != nil { parts.append("録音") }
        parts.append("GPS")
        if !record.photoFileNames.isEmpty { parts.append("両手撮影") }
        if record.screenRecordingFileName != nil { parts.append("画面録画") }
        if !record.witnesses.isEmpty { parts.append("目撃者連絡先\(record.witnesses.count)件") }
        return parts.joined(separator: "+") + " あり"
    }
}

private struct IdentifiableURL: Identifiable {
    let url: URL
    var id: String { url.path }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack { RecordsListView() }
        .environmentObject(ThemeManager())
        .environmentObject(RecordStore())
}
