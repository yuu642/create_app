import SwiftUI
import UIKit

struct RecordingView: View {
    let type: IncidentType

    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var recordStore: RecordStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var coordinator: RecordingCoordinatorBox
    @State private var showCamera = false
    @State private var showPresentScreen = false

    init(type: IncidentType) {
        self.type = type
        _coordinator = StateObject(wrappedValue: RecordingCoordinatorBox())
    }

    var body: some View {
        let palette = themeManager.currentTheme
        VStack(spacing: 14) {
            HStack {
                Text("記録中").font(AppFont.body(13, weight: .medium))
                Spacer()
                Text(coordinator.timerLabel).font(AppFont.mono(11)).foregroundStyle(palette.inkSoft)
            }

            Text(type == .molestation ? "痴漢モード" : "盗撮モード")
                .font(AppFont.body(10, weight: .medium))
                .padding(.horizontal, 9).padding(.vertical, 3)
                .background(type == .molestation ? palette.blueBg : palette.mintBg)
                .foregroundStyle(type == .molestation ? palette.blueDeep : palette.mintDeep)
                .clipShape(Capsule())

            HStack(spacing: 6) {
                Circle().fill(type == .molestation ? palette.blue : palette.mint).frame(width: 7, height: 7)
                Text(type == .molestation ? "REC・自動保存中" : "画面録画・記録中")
                    .font(AppFont.body(10.5, weight: .medium))
            }
            .foregroundStyle(palette.blueDeep)

            Text(coordinator.timerLabel)
                .font(AppFont.mono(30))

            VStack(spacing: 6) {
                metaRow("日時", coordinator.startedAtLabel)
                metaRow("位置情報", coordinator.locationLabel)
                metaRow("記録ID", coordinator.recordCodeLabel)
            }
            .padding(11)
            .background(palette.paperDeep)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            if type == .molestation {
                Button {
                    showCamera = true
                } label: {
                    actionButtonLabel(title: "両手を挙げて撮影", subtitle: "手の位置を証拠として残します", color: palette.blue)
                }
            } else {
                actionButtonLabel(title: "画面録画で記録中", subtitle: "カメラを使っていないことを証拠化", color: palette.mint)
            }

            Button {
                showPresentScreen = true
            } label: {
                Text("相手・周囲に提示する")
                    .font(AppFont.body(11.5, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(palette.ink, lineWidth: 1))
            }
            .foregroundStyle(palette.ink)

            Spacer()

            Button {
                coordinator.stop()
                dismiss()
            } label: {
                Text("停止して保存")
                    .font(AppFont.body(11.5, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(palette.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
        }
        .padding(18)
        .background(palette.paper.ignoresSafeArea())
        .task {
            coordinator.attach(recordStore: recordStore)
            await coordinator.start(type: type)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                onCapture: { image in
                    coordinator.saveHandPhoto(image)
                    showCamera = false
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showPresentScreen) {
            if let record = coordinator.currentSnapshot {
                PresentView(record: record)
            }
        }
    }

    private func metaRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(AppFont.body(10.5)).foregroundStyle(themeManager.currentTheme.inkSoft)
            Spacer()
            Text(value).font(AppFont.mono(10.5))
        }
    }

    private func actionButtonLabel(title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(title).font(AppFont.body(13, weight: .medium))
            Text(subtitle).font(AppFont.body(9.5)).opacity(0.9)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

/// Bridges the environment-independent RecordingCoordinator into this view,
/// exposing display-ready strings the SwiftUI body can read every tick.
@MainActor
final class RecordingCoordinatorBox: ObservableObject {
    @Published var timerLabel = "00:00"
    @Published var startedAtLabel = "--"
    @Published var locationLabel = "取得中..."
    @Published var recordCodeLabel = "--"
    @Published var currentSnapshot: IncidentRecord?

    private var coordinator: RecordingCoordinator?
    private var recordStore: RecordStore?
    private var timer: Timer?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    func attach(recordStore: RecordStore) {
        self.recordStore = recordStore
        guard coordinator == nil else { return }
        coordinator = RecordingCoordinator(recordStore: recordStore)
    }

    func start(type: IncidentType) async {
        guard let coordinator else { return }
        await coordinator.start(type: type)
        currentSnapshot = coordinator.activeRecord
        recordCodeLabel = coordinator.activeRecord?.recordCode ?? "--"
        if let started = coordinator.activeRecord?.startedAt {
            startedAtLabel = dateFormatter.string(from: started)
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        guard let coordinator else { return }
        let total = Int(coordinator.elapsed.rounded())
        timerLabel = String(format: "%02d:%02d", total / 60, total % 60)
        locationLabel = coordinator.locationService.placeDescription
        currentSnapshot = coordinator.activeRecord
    }

    func saveHandPhoto(_ image: UIImage) {
        guard let coordinator, let recordStore, let record = coordinator.activeRecord else { return }
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        let fileName = "hand_\(Int(Date().timeIntervalSince1970)).jpg"
        let fileURL = recordStore.directoryForRecord(record.id).appendingPathComponent(fileName)
        try? data.write(to: fileURL, options: .completeFileProtectionUnlessOpen)
        coordinator.attachHandPhoto(fileName: fileName)
        currentSnapshot = coordinator.activeRecord
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        coordinator?.stop()
    }
}

#Preview {
    RecordingView(type: .molestation)
        .environmentObject(ThemeManager())
        .environmentObject(RecordStore())
}
