import Foundation
import CoreLocation

enum IncidentType: String, Codable, CaseIterable, Identifiable {
    case molestation // 痴漢
    case voyeurism   // 盗撮

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .molestation: return "痴漢を疑われた"
        case .voyeurism: return "盗撮を疑われた"
        }
    }

    var shortLabel: String {
        switch self {
        case .molestation: return "痴漢"
        case .voyeurism: return "盗撮"
        }
    }

    var modeDescription: String {
        switch self {
        case .molestation: return "録音・GPS・両手の位置を記録"
        case .voyeurism: return "録音・GPS・画面録画でカメラ未使用を記録"
        }
    }
}

struct WitnessContact: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var phoneNumber: String
    var note: String
}

/// A single self-defense record. Metadata is stored as JSON on-disk; large media
/// files (audio / screen recording / photos) are referenced by filename only and
/// live alongside the metadata inside RecordStore's protected directory.
struct IncidentRecord: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var type: IncidentType
    var recordCode: String
    var startedAt: Date
    var endedAt: Date?
    var latitude: Double?
    var longitude: Double?
    var locationDescription: String?
    var audioFileName: String?
    var screenRecordingFileName: String?
    var photoFileNames: [String] = []
    var witnesses: [WitnessContact] = []
    var notes: String = ""

    var duration: TimeInterval {
        (endedAt ?? Date()).timeIntervalSince(startedAt)
    }

    var durationLabel: String {
        let total = Int(duration.rounded())
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func generateRecordCode() -> String {
        let suffix = Int.random(in: 10000...99999)
        return "AK-\(suffix)"
    }
}
