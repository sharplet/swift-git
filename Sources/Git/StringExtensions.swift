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

  func sentenceCased() -> String {
    sentenceCased(capitalize: \.capitalized, lowercase: { $0.lowercased() })
  }

  func sentenceCased(with locale: Locale?) -> String {
    sentenceCased(
      capitalize: { $0.capitalized(with: locale) },
      lowercase: { $0.lowercased(with: locale) }
    )
  }

  private func sentenceCased(capitalize: (String) -> String, lowercase: (String) -> String) -> String {
    let string = NSMutableString(string: self)
    let range = NSRange(location: 0, length: string.length)

    withoutActuallyEscaping(capitalize) { capitalize in
      withoutActuallyEscaping(lowercase) { lowercase in
        string.enumerateSubstrings(in: range, options: .bySentences) { substring, range, _, _ in
          var firstWord = (substring! as NSString).rangeOfFirstWord
          firstWord.location = range.location
          let remaining = NSRange(location: firstWord.upperBound, length: range.length - firstWord.length)

          string.replaceCharacters(in: firstWord, with: capitalize(string.substring(with: firstWord)))
          string.replaceCharacters(in: remaining, with: lowercase(string.substring(with: remaining)))
        }
      }
    }

    return string as String
  }
}

private extension NSString {
  var rangeOfFirstWord: NSRange {
    let range = NSRange(location: 0, length: length)
    var firstWord = NSRange(location: 0, length: 0)
    enumerateSubstrings(in: range, options: [.byWords, .substringNotRequired]) { _, range, _, stop in
      firstWord = range
      stop.pointee = true
    }
    return firstWord
  }
}
