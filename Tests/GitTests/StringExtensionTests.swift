@testable import Git
import XCTest

final class StringExtensionTests: XCTestCase {
  func testSentenceCased() {
    XCTAssertEqual("hello world".sentenceCased(), "Hello world")
    XCTAssertEqual("foo? bar.".sentenceCased(), "Foo? Bar.")
    XCTAssertEqual("A Title-Cased String".sentenceCased(), "A title-cased string")
  }
}
