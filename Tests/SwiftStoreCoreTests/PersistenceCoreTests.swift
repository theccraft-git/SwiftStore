import XCTest
@testable import SwiftStoreCore

final class PersistenceCoreTests: XCTestCase {
    func testEncodeDecodeBuild() throws {
        let b = Build(name: "T1", status: .success)
        let data = try JSONEncoder().encode([b])
        let read = try JSONDecoder().decode([Build].self, from: data)
        XCTAssertEqual(read.first?.name, "T1")
    }
}
