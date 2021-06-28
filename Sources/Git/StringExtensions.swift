import Cgit2

extension String {
  init(decoding buffer: git_buf, freeWhenDone: Bool) {
    defer {
      if freeWhenDone {
        var buffer = buffer
        git_buf_free(&buffer)
      }
    }

    let bytes = UnsafeBufferPointer(
      start: UnsafeRawPointer(buffer.ptr).assumingMemoryBound(to: UInt8.self),
      count: buffer.size
    )

    self.init(decoding: bytes, as: UTF8.self)
  }
}
