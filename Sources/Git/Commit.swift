import Cgit2

public struct Commit: _BaseObject {
  let _object: ManagedGitObject
  let repo: Repository

  public let id: ObjectID

  init(id: ObjectID, in repo: Repository) throws {
    let callbacks = GitCallbacks(free: git_commit_free)
    self._object = try .create(withCallbacks: callbacks) { pointer in
      repo._object.withObjectPointer { repo in
        withUnsafePointer(to: id.rawValue) { oid in
          git_commit_lookup(&pointer, repo, oid)
        }
      }
    }
    self.id = id
    self.repo = repo
  }
}

@available(iOS 13, *)
extension Commit: Object {}
