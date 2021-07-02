import Cgit2
import struct Foundation.Data
import struct Foundation.URL
import SystemPackage

public struct Repository {
  let _object: ManagedGitObject
  private var _index: Index!

  fileprivate init(_object: ManagedGitObject) throws {
    self._object = _object
    do {
      self._index = try Index(repository: self)
    } catch GitError.notFound {
      self._index = try Index()
    }
  }

  public var index: Index {
    _index
  }

  public func head() throws -> AnyReference {
    try _object.withUnsafePointer { repo in
      let callbacks = GitCallbacks(free: git_reference_free)
      return AnyReference(
        _object: try .create(withCallbacks: callbacks, operation: "git_repository_head") { pointer in
          git_repository_head(&pointer, repo)
        },
        repository: self
      )
    }
  }
}

extension Repository {
  public struct CloneOptions {
    public var bareRepository: Bool = false

    public static var bareRepository: CloneOptions {
      CloneOptions(bareRepository: true)
    }

    public static var `default`: CloneOptions {
      CloneOptions()
    }
  }
}

extension Repository {
  public static func clone(to path: FilePath, from url: URL, options: CloneOptions = .default) throws -> Repository {
    let callbacks = GitCallbacks(free: git_repository_free)
    return try Repository(
      _object: .create(withCallbacks: callbacks, operation: "git_clone") { pointer in
        var options = git_clone_options()
        let code = git_clone_init_options(&options, UInt32(GIT_CLONE_OPTIONS_VERSION))
        precondition(GIT_OK ~= code)
        return git_clone(&pointer, url.absoluteString, path.string, &options)
      }
    )
  }

  public static func `open`(at path: FilePath) throws -> Repository {
    let callbacks = GitCallbacks(free: git_repository_free)
    return try Repository(
      _object: .create(withCallbacks: callbacks, operation: "git_repository_open") { pointer in
        git_repository_open(&pointer, path.string)
      }
    )
  }
}

extension Repository {
  public func branch(named name: String, type: Branch.BranchType) throws -> Branch? {
    do {
      return try Branch(named: name, ofType: type, in: self)
    } catch GitError.notFound {
      return nil
    }
  }

  public func reset(to commit: Commit, type: ResetType) throws {
    try _object.withUnsafePointer { repo in
      try commit._object.withUnsafePointer { commit in
        try GitError.check(git_reset(repo, commit, git_reset_t(type), nil), operation: "git_reset")
      }
    }
  }
}
