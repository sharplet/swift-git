import Cgit2

public struct AnyReference: ManagedReference {
  private(set) var _reference: ManagedGitPointer
  public let repository: Repository

  public mutating func setTarget<Target: Reference>(_ target: Target, symbolic: Bool) throws {
    let callbacks = GitCallbacks(free: git_reference_free)
    _reference = try .create(withCallbacks: callbacks, operation: "git_reference_set_target") { pointer in
      withUnsafePointer { oldPointer in
        if symbolic {
          return target.repository.withUnsafePointer { repository in
            git_reference_symbolic_create(&pointer, repository, "HEAD", target.fullName, /* force: */ 1, "set_target (symbolic): \(target.fullName)")
          }
        } else {
          return target.commitID.withUnsafePointer { oid in
            git_reference_set_target(&pointer, oldPointer, oid, "set_target (direct): \(target.fullName)")
          }
        }
      }
    }
  }
}
