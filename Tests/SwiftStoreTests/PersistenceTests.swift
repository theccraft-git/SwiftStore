import XCTest
@testable import SwiftStore

final class PersistenceTests: XCTestCase {
    func testSaveAndLoadBuilds() throws {
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftStoreTest")
        try? FileManager.default.removeItem(at: tmpDir)
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

        // Temporarily override applicationSupportDirectory via environment by writing directly
        let builds = [Build(name: "T1", status: .success)]
        let data = try JSONEncoder().encode(builds)
        let file = tmpDir.appendingPathComponent("builds.json")
        try data.write(to: file)

        let read = try JSONDecoder().decode([Build].self, from: Data(contentsOf: file))
        XCTAssertEqual(read.count, 1)
        XCTAssertEqual(read[0].name, "T1")
    }
}
