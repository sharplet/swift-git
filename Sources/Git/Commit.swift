import Cgit2

public struct Commit: ManagedGitObject {
  let _object: ManagedGitPointer
  public let id: ObjectID
  public let repository: Repository

  public init<Reference: Git.Reference>(_ reference: Reference) {
    self.init(id: reference.commitID, in: reference.repository)!
  }

  public init?(id: ObjectID, in repository: Repository) {
    let callbacks = GitCallbacks(free: git_commit_free)
    do {
      self._object = try .create(withCallbacks: callbacks, operation: "git_commit_lookup") { pointer in
        repository.withUnsafePointer { repo in
          id.withUnsafePointer { oid in
            git_commit_lookup(&pointer, repo, oid)
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
extension Commit: Identifiable {}
