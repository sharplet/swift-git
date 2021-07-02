import Cgit2

public struct AnyGitObject: GitObject {
  let _object: ManagedGitObject
  public let id: ObjectID
  public let repository: Repository

  public init?(id: ObjectID, in repository: Repository) {
    do {
      let callbacks = GitCallbacks(free: git_object_free)
      self._object = try .create(withCallbacks: callbacks, operation: "git_object_lookup") { pointer in
        repository._object.withUnsafePointer { repository in
          id.withUnsafePointer { oid in
            git_object_lookup(&pointer, repository, oid, GIT_OBJECT_ANY)
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
