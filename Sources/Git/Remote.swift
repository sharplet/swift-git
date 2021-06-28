import Cgit2

public struct Remote {
  let _object: ManagedGitObject
  let repo: Repository

  init(named name: String, in repo: Repository) throws {
    let callbacks = GitCallbacks(free: git_remote_free)
    self._object = try .create(withCallbacks: callbacks) { pointer in
      repo._object.withObjectPointer { repo in
        git_remote_lookup(&pointer, repo, name)
      }
    }
    self.repo = repo
  }
}
