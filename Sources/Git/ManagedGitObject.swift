protocol ManagedGitObject: GitObject {
  var _object: ManagedGitPointer { get }
}

extension ManagedGitObject {
  func withUnsafePointer<Result>(_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
    try _object.withUnsafePointer(body)
  }
}
