import Cgit2

public struct AnyReference {
  private(set) var _object: ManagedGitObject
  public let repository: Repository

  public mutating func setTarget<Target: Reference>(_ target: Target, symbolic: Bool) throws {
    let callbacks = GitCallbacks(free: git_reference_free)
    _object = try .create(withCallbacks: callbacks) { pointer in
      _object.withObjectPointer { oldPointer in
        if symbolic {
          return git_reference_symbolic_set_target(&pointer, oldPointer, target.name, "set_target (symbolic): \(target.name)")
        } else {
          return target.commitID.withUnsafePointer { oid in
            git_reference_set_target(&pointer, oldPointer, oid, "set_target (direct): \(target.name)")
          }
        }
      }
    }
  }
}

extension AnyReference: Reference {
  public var name: String {
    _object.withObjectPointer { reference in
      String(cString: git_reference_name(reference))
    }
  }
}
