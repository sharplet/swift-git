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
    public var bareRepository: Bool

    public init(bareRepository: Bool = false) {
      self.bareRepository = bareRepository
    }

    public static var bareRepository: CloneOptions {
      CloneOptions(bareRepository: true)
    }

    public static var `default`: CloneOptions {
      CloneOptions()
    }
  }

  public struct InitOptions: OptionSet {
    public var rawValue: CUnsignedInt

    public init(rawValue: CUnsignedInt) {
      self.rawValue = rawValue
    }

    public init(_ flags: git_repository_init_flag_t) {
      self.init(rawValue: flags.rawValue)
    }

    public static var bareRepository: InitOptions {
      InitOptions(GIT_REPOSITORY_INIT_BARE)
    }

    public static var disableReinit: InitOptions {
      InitOptions(GIT_REPOSITORY_INIT_NO_REINIT)
    }

    public static var createIntermediateDirectories: InitOptions {
      InitOptions(GIT_REPOSITORY_INIT_MKPATH)
    }

    public static var createRepositoryDirectories: InitOptions {
      InitOptions(GIT_REPOSITORY_INIT_MKDIR)
    }
  }

  public struct OpenOptions {
    public var initIfNecessary: Bool
    public var initOptions: InitOptions

    public init(initIfNecessary: Bool = false, initOptions: InitOptions = []) {
      self.initIfNecessary = initIfNecessary
      self.initOptions = initOptions
    }

    public static var none: OpenOptions {
      OpenOptions()
    }

    public static var `default`: OpenOptions {
      OpenOptions(
        initIfNecessary: true,
        initOptions: [
          .createIntermediateDirectories,
          .createRepositoryDirectories,
        ]
      )
    }
  }
}

extension Repository {
  public static func clone(
    to path: FilePath,
    from url: URL,
    options: CloneOptions = .default
  ) throws -> Repository {
    try clone(to: path, from: url, options: options, credential: .none)
  }

  public static func clone<Credential: Git.Credential>(
    to path: FilePath,
    from url: URL,
    options: CloneOptions = .default,
    credential: Credential
  ) throws -> Repository {
    let callbacks = GitCallbacks(free: git_repository_free)
    let repository = try Repository(_object: .create(withCallbacks: callbacks, operation: "git_clone") { pointer in
      credential.withCallback { callbackInfo in
        var code: CInt = 0 {
          didSet {
            precondition(GIT_OK ~= code)
          }
        }

        var cloneOptions = git_clone_options()
        code = git_clone_init_options(&cloneOptions, UInt32(GIT_CLONE_OPTIONS_VERSION))

        if let callbackInfo = callbackInfo {
          var callbacks = git_remote_callbacks()
          code = git_remote_init_callbacks(&callbacks, UInt32(GIT_REMOTE_CALLBACKS_VERSION))
          callbacks.credentials = callbackInfo.callback
          callbacks.payload = callbackInfo.payload

          var fetchOptions = git_fetch_options()
          code = git_fetch_init_options(&fetchOptions, UInt32(GIT_FETCH_OPTIONS_VERSION))
          fetchOptions.callbacks = callbacks

          cloneOptions.fetch_opts = fetchOptions
        }

        if options.bareRepository {
          cloneOptions.bare = 1
        }

        return git_clone(&pointer, url.absoluteString, path.string, &cloneOptions)
      }
    })
    print("cloned to '\(path)'")
    return repository
  }

  public func fetch(_ remote: Remote) throws {
    try fetch(remote, credential: .none)
  }

  public func fetch<Credential: Git.Credential>(
    _ remote: Remote,
    credential: Credential
  ) throws {
    try remote._object.withUnsafePointer { remote in
      try credential.withCallback { credential in
        var code: CInt = 0 {
          didSet {
            precondition(GIT_OK ~= code)
          }
        }

        var options = git_fetch_options()
        code = git_fetch_init_options(&options, UInt32(GIT_FETCH_OPTIONS_VERSION))
        precondition(GIT_OK ~= code)

        if let credential = credential {
          var callbacks = git_remote_callbacks()
          code = git_remote_init_callbacks(&callbacks, UInt32(GIT_REMOTE_CALLBACKS_VERSION))
          callbacks.credentials = credential.callback
          callbacks.payload = credential.payload
          options.callbacks = callbacks
        }

        try GitError.check(git_remote_fetch(remote, nil, &options, nil), operation: "git_remote_fetch")
      }
    }
  }

  public static func `open`(at path: FilePath, options: OpenOptions = .none) throws -> Repository {
    let callbacks = GitCallbacks(free: git_repository_free)
    let repository: ManagedGitObject

    do {
      repository = try .create(withCallbacks: callbacks, operation: "git_repository_open") { pointer in
        git_repository_open(&pointer, path.string)
      }
    } catch GitError.notFound where options.initIfNecessary {
      repository = try .create(withCallbacks: callbacks, operation: "git_repository_init_ext") { pointer in
        var initOptions = git_repository_init_options()
        let code = git_repository_init_init_options(&initOptions, UInt32(GIT_REPOSITORY_INIT_OPTIONS_VERSION))
        precondition(GIT_OK ~= code)
        initOptions.flags = options.initOptions.rawValue
        return git_repository_init_ext(&pointer, path.string, &initOptions)
      }
    }

    return try Repository(_object: repository)
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
