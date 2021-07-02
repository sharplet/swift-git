import Cgit2

protocol ManagedReference: Reference {
  var _reference: ManagedGitPointer { get }
}

extension ManagedReference {
  func withUnsafePointer<Result>(_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
    try _reference.withUnsafePointer(body)
  }
}

extension ManagedReference {
  public var fullName: String {
    withUnsafePointer { reference in
      String(cString: git_reference_name(reference))
    }
  }

  public var shorthand: String {
    withUnsafePointer { reference in
      String(cString: git_reference_shorthand(reference))
    }
  }
}
