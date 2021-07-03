import Cgit2

struct GitCallbacks {
  var free: @convention(c) (OpaquePointer?) -> Void
}

class ManagedGitPointer: ManagedBuffer<OpaquePointer, GitCallbacks?> {
  static func create(
    withCallbacks callbacks: GitCallbacks,
    operation: @autoclosure () -> String,
    makingObjectWith init: (inout OpaquePointer?) throws -> CInt
  ) throws -> ManagedGitPointer {
    try create(minimumCapacity: 1) { buffer in
      try buffer.withUnsafeMutablePointerToElements { elements in
        elements.initialize(to: nil)
        var object: OpaquePointer!
        try GitError.check(`init`(&object), operation: operation())
        elements.pointee = callbacks
        return object
      }
    } as! ManagedGitPointer
  }

  func withUnsafePointer<Result>(_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
    try withUnsafeMutablePointerToHeader { header in
      let pointer = header.move()
      defer { header.initialize(to: pointer) }
      return try body(pointer)
    }
  }

  deinit {
    withUnsafeMutablePointers { header, callbacks in
      let (object, callbacks) = (header.move(), callbacks.move())
      callbacks?.free(object)
    }
  }
}
