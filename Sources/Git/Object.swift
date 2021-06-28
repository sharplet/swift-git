import Cgit2


/// Workaround for Identifiable not being available on older platform versions.
/// Prefer `Object` if it is available.
protocol _BaseObject {
  var id: ObjectID { get }
}

@available(iOS 13, *)
protocol Object: _BaseObject, Identifiable {}

public struct ObjectID: RawRepresentable {
  static var _byteCount: Int {
    MemoryLayout<git_oid>.size
  }

  public var rawValue: git_oid

  public init(_ oid: git_oid) {
    self.rawValue = oid
  }

  public init(rawValue: git_oid) {
    self.init(rawValue)
  }

  func withBytes<Result>(_ body: (UnsafeRawBufferPointer) throws -> Result) rethrows -> Result {
    try withUnsafePointer(to: rawValue) { oid in
      let bytes = UnsafeRawBufferPointer(
        start: UnsafeRawPointer(oid),
        count: ObjectID._byteCount
      )
      return try body(bytes)
    }
  }
}

extension ObjectID: CustomStringConvertible {
  public var description: String {
    withBytes { bytes in
      bytes.reduce(into: "") { $0 += String(format: "%02x", $1) }
    }
  }
}

extension ObjectID: Equatable {
  public static func == (lhs: ObjectID, rhs: ObjectID) -> Bool {
    lhs.withBytes { lhs in
      rhs.withBytes { rhs in
        lhs.elementsEqual(rhs)
      }
    }
  }
}

extension ObjectID: Hashable {
  public func hash(into hasher: inout Hasher) {
    withBytes { hasher.combine(bytes: $0) }
  }
}
