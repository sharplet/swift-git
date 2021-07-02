import Cgit2

public protocol Reference {
  var fullName: String { get }
  var shorthand: String { get }
  var repository: Repository { get }
}

extension Reference {
  public var commit: Commit {
    Commit(id: commitID, in: repository)!
  }

  public var commitID: ObjectID {
    repository._object.withUnsafePointer { repository in
      var id = git_oid()
      let code = git_reference_name_to_id(&id, repository, fullName)
      precondition(GIT_OK ~= code)
      return ObjectID(id)
    }
  }
}

protocol ManagedReference: Reference {
  var _object: ManagedGitObject { get }
}

extension ManagedReference {
  public var fullName: String {
    _object.withUnsafePointer { reference in
      String(cString: git_reference_name(reference))
    }
  }

  public var shorthand: String {
    _object.withUnsafePointer { reference in
      String(cString: git_reference_shorthand(reference))
    }
  }
}
