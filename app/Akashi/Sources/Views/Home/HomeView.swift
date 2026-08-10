import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var recordStore: RecordStore
    @State private var selectedType: IncidentType?
    @State private var showAlarm = false

    var body: some View {
        let palette = themeManager.currentTheme
        Group {
            ScrollView {
                VStack(spacing: 10) {
                    Text("疑われた内容を選ぶと、必要な証拠を\n自動で記録するモードに切り替わります")
                        .font(AppFont.body(11))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(palette.inkSoft)
                        .padding(.top, 4)

                    ForEach(IncidentType.allCases) { type in
                        Button {
                            selectedType = type
                        } label: {
                            EntryCardView(type: type, palette: palette)
                        }
                        .buttonStyle(.plain)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        NavigationLink {
                            GuideView()
                        } label: {
                            TileView(title: "対処法ガイド", subtitle: "今すぐ確認", palette: palette)
                        }
                        NavigationLink {
                            GuideView(scrollToHotline: true)
                        } label: {
                            TileView(title: "弁護士に連絡", subtitle: "24時間ホットライン", palette: palette)
                        }
                        NavigationLink {
                            RecordsListView()
                        } label: {
                            TileView(title: "記録一覧", subtitle: "過去\(recordStore.records.count)件を保存中", palette: palette)
                        }
                        Button {
                            showAlarm = true
                        } label: {
                            TileView(title: "冤罪アラーム", subtitle: "周囲に知らせる", palette: palette)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
            .background(palette.paper.ignoresSafeArea())
            .navigationTitle("あかし")
            .fullScreenCover(item: $selectedType) { type in
                RecordingView(type: type)
            }
            .fullScreenCover(isPresented: $showAlarm) {
                AlarmView()
            }
        }
    }
}

private struct EntryCardView: View {
    let type: IncidentType
    let palette: AppPalette

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(type == .molestation ? palette.blue : palette.mint)
                    .frame(width: 44, height: 44)
                Text(type.shortLabel)
                    .font(AppFont.headline(12))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(type.displayName)
                    .font(AppFont.body(13, weight: .medium))
                    .foregroundStyle(type == .molestation ? palette.blueDeep : palette.mintDeep)
                Text(type.modeDescription)
                    .font(AppFont.body(9.5))
                    .foregroundStyle(palette.inkSoft)
            }
            Spacer()
        }
        .padding(14)
        .background(type == .molestation ? palette.blueBg : palette.mintBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct TileView: View {
    let title: String
    let subtitle: String
    let palette: AppPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(AppFont.body(12, weight: .medium)).foregroundStyle(palette.ink)
            Text(subtitle).font(AppFont.body(10)).foregroundStyle(palette.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(11)
        .background(palette.paperDeep)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(palette.line, lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    HomeView()
        .environmentObject(ThemeManager())
        .environmentObject(RecordStore())
}
