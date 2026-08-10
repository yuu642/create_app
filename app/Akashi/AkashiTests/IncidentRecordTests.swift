import XCTest
@testable import Akashi

final class IncidentRecordTests: XCTestCase {
    func testDurationLabelFormatsMinutesAndSeconds() {
        let start = Date(timeIntervalSince1970: 0)
        var record = IncidentRecord(type: .molestation, recordCode: "AK-00001", startedAt: start)
        record.endedAt = start.addingTimeInterval(125)
        XCTAssertEqual(record.durationLabel, "02:05")
    }

    func testRecordCodeHasExpectedPrefix() {
        let code = IncidentRecord.generateRecordCode()
        XCTAssertTrue(code.hasPrefix("AK-"))
    }
}
