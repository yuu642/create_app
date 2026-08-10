import Foundation
import ReplayKit

/// Records the app's own screen via ReplayKit while the user is in voyeurism ("盗撮")
/// mode, so they can prove the camera was not open during the incident. iOS does not
/// expose other apps' usage history or camera activation logs to third-party apps, so
/// this in-app screen recording is the closest technically-feasible equivalent.
@MainActor
final class ScreenRecordingService: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var lastError: String?

    private let recorder = RPScreenRecorder.shared()
    private var outputURL: URL?

    var isAvailable: Bool { recorder.isAvailable }

    func startRecording(in directory: URL, completion: @escaping (String?) -> Void) {
        guard recorder.isAvailable else {
            lastError = "この端末では画面録画を利用できません"
            completion(nil)
            return
        }
        recorder.isMicrophoneEnabled = true
        recorder.startRecording { [weak self] error in
            guard let self else { return }
            Task { @MainActor in
                if let error {
                    self.lastError = error.localizedDescription
                    completion(nil)
                } else {
                    self.isRecording = true
                    let fileName = "screen_\(Int(Date().timeIntervalSince1970)).mp4"
                    self.outputURL = directory.appendingPathComponent(fileName)
                    completion(fileName)
                }
            }
        }
    }

    func stopRecording(completion: @escaping (Bool) -> Void) {
        guard let outputURL else {
            completion(false)
            return
        }
        recorder.stopRecording(withOutput: outputURL) { [weak self] error in
            Task { @MainActor in
                guard let self else { return }
                self.isRecording = false
                if let error {
                    self.lastError = error.localizedDescription
                    completion(false)
                } else {
                    try? FileManager.default.setAttributes(
                        [.protectionKey: FileProtectionType.completeUnlessOpen],
                        ofItemAtPath: outputURL.path
                    )
                    completion(true)
                }
                self.outputURL = nil
            }
        }
    }
}
