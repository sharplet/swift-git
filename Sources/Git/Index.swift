import Cgit2
import SystemPackage

public struct Index {
  let _object: ManagedGitObject

  public init() throws {
    let callbacks = GitCallbacks(free: git_index_free)
    self._object = try .create(withCallbacks: callbacks, operation: "git_index_new") { pointer in
      git_index_new(&pointer)
    }
  }

  public init(repository: Repository) throws {
    let callbacks = GitCallbacks(free: git_index_free)
    self._object = try .create(withCallbacks: callbacks, operation: "git_repository_index") { pointer in
      repository._object.withUnsafePointer { repository in
        git_repository_index(&pointer, repository)
      }
    }
  }

  public subscript(path: FilePath) -> Index.Entry? {
    _object.withUnsafePointer { index in
      git_index_get_bypath(index, path.string, GIT_INDEX_STAGE_ANY.rawValue)
        .map(Entry.init)
    }
  }
}

extension Index {
//  public func contents(ofFileAt path: FilePath) throws -> Data {
//    guard let repo = repo else { throw RepositoryError.notOpened }
//
//    var i = 0
//    try check(git_index_find(&i, index._index, path.string))
//    let entry = git_index_get_byindex(index._index, i)!
//
//    var blob: OpaquePointer!
//    try check(git_blob_lookup(&blob, repo.pointer, entry[\.id]))
//    defer { git_blob_free(blob) }
//
//    let count = Int(git_blob_rawsize(blob))
//    let bytes = git_blob_rawcontent(blob)!
//    return Data(bytes: bytes, count: count)
//  }

  public func readTree<Reference: Git.Reference>(at reference: Reference) throws {
    try read(Tree(reference))
  }

  public func read(_ tree: Tree) throws {
    let code = _object.withUnsafePointer { index in
      tree._object.withUnsafePointer { tree in
        git_index_read_tree(index, tree)
      }
    }
    try GitError.check(code, operation: "git_index_read_tree")
  }
}

extension Index {
  public struct Entry: Hashable {
    public let id: ObjectID
    public let path: FilePath

    fileprivate init(_ entry: UnsafePointer<git_index_entry>) {
      let entry = entry.pointee
      self.id = ObjectID(entry.id)
      self.path = FilePath(cString: entry.path)
    }
  }

  public var entries: EntryView {
    EntryView(index: self)
  }

  public struct EntryView: RandomAccessCollection {
    fileprivate var index: Index

    public var startIndex: Int {
      0
    }

    public var endIndex: Int {
      index._object.withUnsafePointer(git_index_entrycount)
    }

    public subscript(position: Int) -> Index.Entry {
      index._object.withUnsafePointer { index in
        Entry(git_index_get_byindex(index, position))
      }
    }
  }
}
