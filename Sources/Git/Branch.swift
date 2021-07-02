import Cgit2

public struct Branch: ManagedReference {
  let _object: ManagedGitObject
  public let repository: Repository

  init(named name: String, ofType type: BranchType, in repo: Repository) throws {
    let callbacks = GitCallbacks(free: git_reference_free)
    self._object = try .create(withCallbacks: callbacks, operation: "git_branch_lookup") { pointer in
      repo._object.withUnsafePointer { repo in
        git_branch_lookup(&pointer, repo, name, git_branch_t(type))
      }
    }
    self.repository = repo
  }

  init(_object: ManagedGitObject, repository: Repository) {
    self._object = _object
    self.repository = repository
  }

  public var shorthand: String {
    _object.withUnsafePointer { branch in
      var name: UnsafePointer<CChar>!
      let code = git_branch_name(&name, branch)
      precondition(GIT_OK ~= code)
      return String(cString: name)
    }
  }

  public var upstream: Branch? {
    _object.withUnsafePointer { branch in
      do {
        let callbacks = GitCallbacks(free: git_reference_free)
        return Branch(
          _object: try .create(withCallbacks: callbacks, operation: "git_branch_upstream") { upstream in
            git_branch_upstream(&upstream, branch)
          },
          repository: repository
        )
      } catch {
        return nil
      }
    }
  }

  public var upstreamRemote: Remote? {
    do {
      let name = try repository._object.withUnsafePointer { repo -> String in
        try _object.withUnsafePointer { branch in
          var buffer = git_buf()
          let fullName = git_reference_name(branch)
          try GitError.check(git_branch_upstream_remote(&buffer, repo, fullName), operation: "git_branch_upstream_remote")
          return String(decoding: buffer, freeWhenDone: true)
        }
      }
      return try! Remote(named: name, in: repository)
    } catch {
      return nil
    }
  }
}

extension Branch {
  public init?<Other: Reference>(_ reference: Other) {
    do {
      try self.init(named: reference.shorthand, ofType: .local, in: reference.repository)
    } catch {
      try? self.init(named: reference.shorthand, ofType: .remote, in: reference.repository)
    }
  }
}

extension Branch {
  public struct BranchType: OptionSet {
    public typealias RawValue = git_branch_t.RawValue

    public var rawValue: RawValue = 0

    public init(rawValue: RawValue) {
      self.rawValue = rawValue
    }

    public static let local = BranchType(rawValue: GIT_BRANCH_LOCAL.rawValue)
    public static let remote = BranchType(rawValue: GIT_BRANCH_REMOTE.rawValue)
    public static let all = BranchType(rawValue: GIT_BRANCH_ALL.rawValue)
  }
}

extension git_branch_t: RawRepresentable {}

extension git_branch_t {
  init(_ type: Branch.BranchType) {
    self.init(rawValue: type.rawValue)
  }
}
