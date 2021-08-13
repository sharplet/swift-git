import GitSystem
import XCTest

final class FilePathExtensionTests: XCTestCase {
  func testLastComponent() {
    XCTAssertEqual(FilePath("/foo").swiftgit_lastComponent, "foo")
    XCTAssertEqual(FilePath("foo").swiftgit_lastComponent, "foo")
    XCTAssertEqual(FilePath(".").swiftgit_lastComponent, ".")
    XCTAssertNil(FilePath("").swiftgit_lastComponent)
    XCTAssertNil(FilePath("/").swiftgit_lastComponent)
  }

  func testRemoveLastComponent() {
    XCTAssertEqual(FilePath("/foo").swiftgit_removingLastComponent(), "/")
    XCTAssertEqual(FilePath("/").swiftgit_removingLastComponent(), "/")
    XCTAssertEqual(FilePath(".").swiftgit_removingLastComponent(), "")
    XCTAssertEqual(FilePath("").swiftgit_removingLastComponent(), "")
  }
}
