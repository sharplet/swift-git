import Foundation

#if DEBUG
@usableFromInline
var _isTesting: Bool {
  NSClassFromString("XCTestCase") != nil
}
#else
@usableFromInline
let _isTesting = false
#endif

extension FilePath {
  @inlinable
  public var swiftgit_lastComponent: String? {
    if !_isTesting, #available(macOS 12, *) {
      return lastComponent?.string
    } else {
      let components = (withCString(String.init(cString:)) as NSString).pathComponents
      guard !components.isEmpty, components != ["/"] else { return nil }
      return components.last
    }
  }

  @inlinable
  public mutating func swiftgit_removeLastComponent() {
    if !_isTesting, #available(macOS 12, *) {
      removeLastComponent()
    } else {
      let string = (withCString(String.init(cString:)) as NSString).deletingLastPathComponent
      self = FilePath(string)
    }
  }

  @inlinable
  public func swiftgit_removingLastComponent() -> FilePath {
    if !_isTesting, #available(macOS 12, *) {
      return removingLastComponent()
    } else {
      var copy = self
      copy.swiftgit_removeLastComponent()
      return copy
    }
  }
}
