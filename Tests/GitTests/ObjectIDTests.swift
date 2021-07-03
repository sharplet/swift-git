import Cgit2
@testable import Git
import XCTest

final class ObjectIDTests: XCTestCase {
  func testMemoryLayout() {
    XCTAssertEqual(ObjectID._byteCount, 20)
  }

  func testDescription() {
    let null = ObjectID(git_oid())
    XCTAssertEqual("\(null)", "0000000000000000000000000000000000000000")
    let sha = ObjectID(git_oid(id: (0x9B, 0x63, 0xFE, 0xA0, 0x6D, 0x1F, 0xBC, 0x52, 0x53, 0x66, 0xE4, 0xB0, 0xB4, 0x76, 0x37, 0xC2, 0xE1, 0xEB, 0x8D, 0xE0)))
    XCTAssertEqual("\(sha)", "9b63fea06d1fbc525366e4b0b47637c2e1eb8de0")
  }
}
