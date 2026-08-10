import Foundation

/// Persists IncidentRecords to an on-device, file-protected directory.
/// Nothing here ever leaves the device automatically; sharing only happens
/// when the user explicitly exports a record (see RecordStore.exportPackage).
@MainActor
final class RecordStore: ObservableObject {
    @Published private(set) var records: [IncidentRecord] = []

    private let fileManager = FileManager.default
    private let indexFileName = "records_index.json"

    private lazy var rootDirectory: URL = {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = documents.appendingPathComponent("AkashiRecords", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: [
                .protectionKey: FileProtectionType.completeUnlessOpen
            ])
        }
        return dir
    }()

    private var indexURL: URL {
        rootDirectory.appendingPathComponent(indexFileName)
    }

    init() {
        load()
    }

    func directoryForRecord(_ id: UUID) -> URL {
        let dir = rootDirectory.appendingPathComponent(id.uuidString, isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: [
                .protectionKey: FileProtectionType.completeUnlessOpen
            ])
        }
        return dir
    }

    func upsert(_ record: IncidentRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.insert(record, at: 0)
        }
        save()
    }

    func delete(_ record: IncidentRecord) {
        records.removeAll { $0.id == record.id }
        try? fileManager.removeItem(at: directoryForRecord(record.id))
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: indexURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([IncidentRecord].self, from: data) {
            records = decoded.sorted { $0.startedAt > $1.startedAt }
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records) else { return }
        try? data.write(to: indexURL, options: [.completeFileProtectionUnlessOpen])
    }

    /// Bundles a record's metadata + media into a single folder the user can
    /// share via the system share sheet (police / lawyer / self). This is the
    /// only path by which record data leaves the device.
    func exportPackage(for record: IncidentRecord) -> URL? {
        let sourceDir = directoryForRecord(record.id)
        let exportDir = fileManager.temporaryDirectory.appendingPathComponent("akashi_export_\(record.recordCode)", isDirectory: true)
        try? fileManager.removeItem(at: exportDir)
        do {
            try fileManager.copyItem(at: sourceDir, to: exportDir)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let summaryData = try encoder.encode(record)
            try summaryData.write(to: exportDir.appendingPathComponent("summary.json"))
            return exportDir
        } catch {
            return nil
        }
    }
}
