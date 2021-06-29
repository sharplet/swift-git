import Cgit2

public protocol Reference {
  var name: String { get }
  var repository: Repository { get }
}

extension Reference {
  public var commit: Commit {
    Commit(id: commitID, in: repository)!
  }

  public var commitID: ObjectID {
    repository._object.withObjectPointer { repo in
      var id = git_oid()
      let code = git_reference_name_to_id(&id, repo, name)
      precondition(GIT_OK ~= code)
      return ObjectID(id)
    }
  }
}
