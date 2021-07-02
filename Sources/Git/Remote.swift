import Cgit2

public struct Remote {
  let _remote: ManagedGitPointer
  let repository: Repository

  init(named name: String, in repository: Repository) throws {
    let callbacks = GitCallbacks(free: git_remote_free)
    self._remote = try .create(withCallbacks: callbacks, operation: "git_remote_lookup") { pointer in
      repository.withUnsafePointer { repository in
        git_remote_lookup(&pointer, repository, name)
      }
    }
    self.repository = repository
  }

  func withUnsafePointer<Result>(_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
    try _remote.withUnsafePointer(body)
  }
}
