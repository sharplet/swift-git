import Cgit2
import Foundation

public struct Blob: GitObject {
  let _object: ManagedGitObject
  public let id: ObjectID
  public let repository: Repository

  public init?(id: ObjectID, in repository: Repository) {
    do {
      let callbacks = GitCallbacks(free: git_blob_free)
      self.id = id
      self.repository = repository
      self._object = try .create(withCallbacks: callbacks, operation: "git_blob_lookup") { pointer in
        repository._object.withUnsafePointer { repository in
          id.withUnsafePointer { oid in
            git_blob_lookup(&pointer, repository, oid)
          }
        }
      }
    } catch {
      return nil
    }
  }
}

extension Blob {
  public var data: Data {
    _object.withUnsafePointer { blob in
      let count = Int(git_blob_rawsize(blob))
      let bytes = git_blob_rawcontent(blob)!
      return Data(bytes: bytes, count: count)
    }
  }
}
