import Cgit2

public struct Commit: _BaseObject {
  let _object: ManagedGitObject
  public let id: ObjectID
  public let repository: Repository

  public init?(id: ObjectID, in repo: Repository) {
    let callbacks = GitCallbacks(free: git_commit_free)
    do {
      self._object = try .create(withCallbacks: callbacks) { pointer in
        repo._object.withObjectPointer { repo in
          id.withUnsafePointer { oid in
            git_commit_lookup(&pointer, repo, oid)
          }
        }
      }
      self.id = id
      self.repository = repo
    } catch {
      return nil
    }
  }
}

@available(iOS 13, *)
extension Commit: Object {}

extension Commit: Equatable {
  public static func ==(lhs: Commit, rhs: Commit) -> Bool {
    lhs.id == rhs.id
  }
}

extension Commit: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
