@testable import Git
import Cgit2
import XCTest

final class ObjectIDTests: XCTestCase {
  func testMemoryLayout() {
    XCTAssertEqual(ObjectID._byteCount, 20)
  }

  func testDescription() {
    let null = ObjectID(git_oid())
    XCTAssertEqual("\(null)", "0000000000000000000000000000000000000000")
    let sha = ObjectID(git_oid(id: (0x9b, 0x63, 0xfe, 0xa0, 0x6d, 0x1f, 0xbc, 0x52, 0x53, 0x66, 0xe4, 0xb0, 0xb4, 0x76, 0x37, 0xc2, 0xe1, 0xeb, 0x8d, 0xe0)))
    XCTAssertEqual("\(sha)", "9b63fea06d1fbc525366e4b0b47637c2e1eb8de0")
  }
}
