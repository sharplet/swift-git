import Cgit2

protocol GitObject: Hashable {
  var id: ObjectID { get }
  var repository: Repository { get }
  init?(id: ObjectID, in repository: Repository)
}

extension GitObject {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

extension GitObject {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

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

  func withUnsafePointer<Result>(_ body: (UnsafePointer<git_oid>) throws -> Result) rethrows -> Result {
    try Swift.withUnsafePointer(to: rawValue, body)
  }

  func withUnsafeBytes<Result>(_ body: (UnsafeRawBufferPointer) throws -> Result) rethrows -> Result {
    try withUnsafePointer { oid in
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
    withUnsafeBytes { bytes in
      bytes.reduce(into: "") { $0 += String(format: "%02x", $1) }
    }
  }
}

extension ObjectID: Equatable {
  public static func == (lhs: ObjectID, rhs: ObjectID) -> Bool {
    lhs.withUnsafeBytes { lhs in
      rhs.withUnsafeBytes { rhs in
        lhs.elementsEqual(rhs)
      }
    }
  }
}

extension ObjectID: Hashable {
  public func hash(into hasher: inout Hasher) {
    withUnsafeBytes { hasher.combine(bytes: $0) }
  }
}
