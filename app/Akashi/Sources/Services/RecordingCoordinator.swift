import Foundation
import CoreLocation

/// Coordinates the audio / location / screen-recording services during an
/// active incident recording session, independent of any particular view.
@MainActor
final class RecordingCoordinator: ObservableObject {
    @Published private(set) var activeRecord: IncidentRecord?
    @Published private(set) var handPhotoFileName: String?

    let audioService = AudioRecordingService()
    let locationService = LocationService()
    let screenService = ScreenRecordingService()

    private let recordStore: RecordStore

    init(recordStore: RecordStore) {
        self.recordStore = recordStore
    }

    var elapsed: TimeInterval { audioService.elapsed }
    var isActive: Bool { activeRecord != nil }

    func start(type: IncidentType) async {
        locationService.requestAuthorization()
        locationService.startUpdating()

        var record = IncidentRecord(
            type: type,
            recordCode: IncidentRecord.generateRecordCode(),
            startedAt: Date()
        )

        let directory = recordStore.directoryForRecord(record.id)

        let granted = await audioService.requestPermission()
        if granted {
            record.audioFileName = audioService.startRecording(in: directory)
        }

        if type == .voyeurism, screenService.isAvailable {
            screenService.startRecording(in: directory) { [weak self] fileName in
                self?.activeRecord?.screenRecordingFileName = fileName
            }
        }

        activeRecord = record
        recordStore.upsert(record)
    }

    func attachHandPhoto(fileName: String) {
        handPhotoFileName = fileName
        activeRecord?.photoFileNames.append(fileName)
        if let record = activeRecord {
            recordStore.upsert(record)
        }
    }

    func stop() {
        guard var record = activeRecord else { return }
        audioService.stopRecording()
        locationService.stopUpdating()

        if let location = locationService.currentLocation {
            record.latitude = location.coordinate.latitude
            record.longitude = location.coordinate.longitude
        }
        record.locationDescription = locationService.placeDescription
        record.endedAt = Date()

        if screenService.isRecording {
            screenService.stopRecording { [weak self] _ in
                guard let self else { return }
                self.recordStore.upsert(record)
            }
        }

        recordStore.upsert(record)
        activeRecord = nil
        handPhotoFileName = nil
    }
}
