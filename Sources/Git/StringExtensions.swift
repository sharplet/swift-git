import Cgit2
import Foundation

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

  func sentenceCased(with locale: Locale?) -> String {
    let string = NSMutableString(string: self)
    let range = NSRange(location: 0, length: string.length)
    string.enumerateSubstrings(in: range, options: [.bySentences, .substringNotRequired]) { _, range, _, _ in
      var wordEnd = string.rangeOfCharacter(from: .whitespacesAndNewlines).location
      if wordEnd == NSNotFound {
        wordEnd = range.upperBound
      }
      let firstWord = NSRange(location: range.location, length: wordEnd - range.location)
      string.replaceCharacters(in: firstWord, with: string.substring(with: firstWord).capitalized(with: locale))
    }
    return string as String
  }
}
