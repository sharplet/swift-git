import Cgit2

struct GitCallbacks {
  var free: @convention(c) (OpaquePointer?) -> Void
}

class ManagedGitObject: ManagedBuffer<OpaquePointer, GitCallbacks> {
  static func create(
    withCallbacks callbacks: GitCallbacks,
    makingObjectWith `init`: (inout OpaquePointer?) -> CInt
  ) throws -> ManagedGitObject {
    try create(minimumCapacity: 1) { buffer in
      try buffer.withUnsafeMutablePointerToElements { elements in
        var object: OpaquePointer!
        try check(git_error_code(`init`(&object)))
        elements.initialize(to: callbacks)
        return object
      }
    } as! ManagedGitObject
  }

  func withObjectPointer<Result>(_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
    try withUnsafeMutablePointerToHeader { header in
      let pointer = header.move()
      defer { header.initialize(to: pointer) }
      return try body(pointer)
    }
  }

  deinit {
    withUnsafeMutablePointers { header, callbacks in
      let (object, callbacks) = (header.move(), callbacks.move())
      callbacks.free(object)
    }
  }
}
