import Cgit2
import Foundation
import SystemPackage

public struct Repository {
  public let path: FilePath

  let _repository: ManagedGitPointer
  private var _index: Index!

  fileprivate init(path: FilePath, _repository: ManagedGitPointer) throws {
    self.path = path
    self._repository = _repository
    do {
      self._index = try Index(repository: self)
    } catch GitError.notFound {
      self._index = try Index()
    }
  }

  func withUnsafePointer<Result>(_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
    try _repository.withUnsafePointer(body)
  }

  public var index: Index {
    _index
  }

  public func head() throws -> AnyReference {
    try withUnsafePointer { repo in
      let callbacks = GitCallbacks(free: git_reference_free)
      return AnyReference(
        _reference: try .create(withCallbacks: callbacks, operation: "git_repository_head") { pointer in
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
    options: CloneOptions = .default,
    progressHandler: ((TransferProgress) -> Void)? = nil
  ) throws -> Repository {
    try clone(
      to: path,
      from: url,
      options: options,
      credential: NullCredential(),
      progressHandler: progressHandler
    )
  }

  public static func clone<Credential: Git.Credential>(
    to path: FilePath,
    from url: URL,
    options: CloneOptions = .default,
    credential: Credential,
    progressHandler: ((TransferProgress) -> Void)? = nil
  ) throws -> Repository {
    let callbacks = GitCallbacks(free: git_repository_free)
    let repository = try Repository(path: path, _repository: .create(withCallbacks: callbacks, operation: "git_clone") { pointer in
      var code: CInt = 0 {
        didSet {
          precondition(GIT_OK ~= code)
        }
      }

      let delegate = FetchDelegate(
        credential: credential,
        progressHandler: progressHandler
      )

      var fetchOptions = git_fetch_options()
      code = git_fetch_init_options(&fetchOptions, UInt32(GIT_FETCH_OPTIONS_VERSION))
      fetchOptions.callbacks = delegate.callbacks

      var cloneOptions = git_clone_options()
      code = git_clone_init_options(&cloneOptions, UInt32(GIT_CLONE_OPTIONS_VERSION))
      cloneOptions.fetch_opts = fetchOptions

      if options.bareRepository {
        cloneOptions.bare = 1
      }

      return withExtendedLifetime(delegate) {
        git_clone(&pointer, url.absoluteString, path.string, &cloneOptions)
      }
    })
    return repository
  }

  public static func open(at path: FilePath, options: OpenOptions = .none) throws -> Repository {
    let callbacks = GitCallbacks(free: git_repository_free)
    var path = path
    let repository: ManagedGitPointer

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

    if path.lastComponent == ".git" {
      path.removeLastComponent()
    }

    return try Repository(path: path, _repository: repository)
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

  public func fetch(_ remote: Remote, progressHandler: ((TransferProgress) -> Void)? = nil) throws {
    try fetch(remote, credential: NullCredential(), progressHandler: progressHandler)
  }

  public func fetch<Credential: Git.Credential>(
    _ remote: Remote,
    credential: Credential,
    progressHandler: ((TransferProgress) -> Void)? = nil
  ) throws {
    try remote.withUnsafePointer { remote in
      var code: CInt = 0 {
        didSet {
          precondition(GIT_OK ~= code)
        }
      }

      let delegate = FetchDelegate(
        credential: credential,
        progressHandler: progressHandler
      )

      var options = git_fetch_options()
      code = git_fetch_init_options(&options, UInt32(GIT_FETCH_OPTIONS_VERSION))
      precondition(GIT_OK ~= code)
      options.callbacks = delegate.callbacks

      try withExtendedLifetime(delegate) {
        try GitError.check(git_remote_fetch(remote, nil, &options, nil), operation: "git_remote_fetch")
      }
    }
  }

  public func reset(to commit: Commit, type: ResetType) throws {
    try _repository.withUnsafePointer { repo in
      try commit._object.withUnsafePointer { commit in
        try GitError.check(git_reset(repo, commit, git_reset_t(type), nil), operation: "git_reset")
      }
    }
  }
}
