import Cgit2
import Foundation

func check(_ code: git_error_code.RawValue) throws {
  try check(git_error_code(code))
}

func check(_ result: git_error_code) throws {
  guard case GIT_OK = result else {
    throw GitError.last ?? GitError(result)
  }
}

public struct GitError: _BridgedStoredNSError {
  public typealias Code = git_error_code

  public static var errorDomain: String {
    "org.libgit2"
  }

  public static var _nsErrorDomain: String {
    errorDomain
  }

  public let _nsError: NSError

  public init(_nsError: NSError) {
    self._nsError = _nsError
  }
}

extension GitError {
  static var last: GitError? {
    guard let error = giterr_last()?.pointee else { return nil }
    let code = git_error_code(rawValue: error.klass)
    let failureReason = String(cString: error.message)
    return GitError(code, userInfo: [NSLocalizedFailureReasonErrorKey: failureReason])
  }
}

extension git_error_code: _ErrorCodeProtocol {
  public typealias _ErrorType = GitError

  public static var ambiguous: git_error_code {
    GIT_EAMBIGUOUS
  }

  public static var generic: git_error_code {
    GIT_ERROR
  }

  public static var notFound: git_error_code {
    GIT_ENOTFOUND
  }

  public static var unbornBranch: git_error_code {
    GIT_EUNBORNBRANCH
  }
}

extension GitError {
  public static var ambiguous: git_error_code {
    .ambiguous
  }

  public static var generic: git_error_code {
    .generic
  }

  public static var notFound: git_error_code {
    .notFound
  }

  public static var unbornBranch: git_error_code {
    .unbornBranch
  }
}

extension git_error_code {
  public static func ~=(pattern: git_error_code, error: Error) -> Bool {
    let error = error as NSError
    return error.domain == _ErrorType.errorDomain && error.code == pattern.rawValue
  }

  public static func ~=(pattern: git_error_code, code: CInt) -> Bool {
    pattern.rawValue == code
  }
}
