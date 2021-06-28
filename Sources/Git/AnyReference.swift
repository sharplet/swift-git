import Cgit2

public struct AnyReference {
  let _object: ManagedGitObject
  public let repository: Repository

  public var commitID: ObjectID {
    repository._object.withObjectPointer { repo in
      var id = git_oid()
      let code = git_reference_name_to_id(&id, repo, name)
      precondition(GIT_OK ~= code)
      return ObjectID(id)
    }
  }
}

extension AnyReference: Reference {
  public var name: String {
    _object.withObjectPointer { reference in
      String(cString: git_reference_name(reference))
    }
  }
}
