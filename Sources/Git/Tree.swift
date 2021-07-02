import Cgit2

public struct Tree: ManagedGitObject {
  let _object: ManagedGitPointer
  public let id: ObjectID
  public let repository: Repository

  public init<Reference: Git.Reference>(_ reference: Reference) throws {
    let callbacks = GitCallbacks(free: git_tree_free)
    self.id = reference.commitID
    self.repository = reference.repository
    self._object = try .create(withCallbacks: callbacks, operation: "git_reference_peel") { [repository] pointer in
      if let reference = reference as? ManagedReference {
        return reference.withUnsafePointer { reference in
          git_reference_peel(&pointer, reference, GIT_OBJECT_TREE)
        }
      } else {
        let anyObject = AnyGitObject(id: reference.commitID, in: repository)!
        return anyObject._object.withUnsafePointer { anyObject in
          git_object_peel(&pointer, anyObject, GIT_OBJECT_TREE)
        }
      }
    }
  }

  public init?(id: ObjectID, in repository: Repository) {
    let callbacks = GitCallbacks(free: git_tree_free)
    do {
      self._object = try .create(withCallbacks: callbacks, operation: "git_tree_lookup") { pointer in
        repository.withUnsafePointer { repository in
          id.withUnsafePointer { oid in
            git_tree_lookup(&pointer, repository, oid)
          }
        }
      }
      self.id = id
      self.repository = repository
    } catch {
      return nil
    }
  }
}

@available(iOS 13, macOS 15, *)
extension Tree: Identifiable {}
