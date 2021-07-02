import Cgit2
import Foundation

public struct GitError: Error {
  public static var errorDomain: String {
    "org.libgit2"
  }

  public var code: GitErrorCode
  public var operation: String
  public var details: GitErrorDetails?

  public init(_ code: GitErrorCode, operation: String, details: GitErrorDetails? = nil) {
    self.code = code
    self.operation = operation
    self.details = details
  }

  public init(_ code: GitErrorCode, operation: String, class: GitErrorClass, message: String) {
    self.init(code, operation: operation, details: GitErrorDetails(class: `class`, message: message))
  }
}

extension GitError {
  public static func check(_ code: git_error_code.RawValue, operation: @autoclosure () -> String) throws {
    try check(git_error_code(code), operation: operation())
  }

  public static func check(_ result: git_error_code, operation: @autoclosure () -> String) throws {
    if let code = GitErrorCode(result) {
      throw GitError.getLast(code: code, operation: operation())
    }
  }

  public static func getLast(code: GitErrorCode, operation: String) -> GitError {
    if let error = git_error_last()?.pointee, let `class` = GitErrorClass(rawValue: error.klass) {
      let message = String(cString: error.message)
      git_error_clear()
      return GitError(code, operation: operation, class: `class`, message: message)
    } else {
      return GitError(code, operation: operation)
    }
  }
}

extension GitError: CustomNSError {
  public var errorCode: Int {
    Int(code.rawValue)
  }

  public var errorUserInfo: [String: Any] {
    let userInfo = [
      NSLocalizedDescriptionKey: errorDescription,
      NSLocalizedFailureReasonErrorKey: failureReason,
    ]
    return userInfo.compactMapValues { $0 }
  }
}

extension GitError: LocalizedError {
  public var errorDescription: String? {
    details?.errorDescription
  }

  public var failureReason: String? {
    details?.failureReason(withOperation: operation)
  }
}

public struct GitErrorDetails {
  public var `class`: GitErrorClass
  public var message: String

  public init(class: GitErrorClass, message: String) {
    self.class = `class`
    self.message = message
  }

  public init(_ error: git_error) {
    self.class = GitErrorClass(rawValue: CUnsignedInt(error.klass))!
    self.message = String(cString: error.message)
  }

  public var errorDescription: String? {
    guard !message.isEmpty else { return nil }
    return message.sentenceCased(with: .current) + "."
  }

  public func failureReason(withOperation operation: String) -> String {
    "\(operation): \(`class`)."
  }
}

public struct GitErrorCode: RawRepresentable {
  public var rawValue: CInt

  public init?(rawValue: CInt) {
    guard rawValue != GIT_OK.rawValue else { return nil }
    self.rawValue = rawValue
  }

  public init?(_ code: git_error_code) {
    self.init(rawValue: code.rawValue)
  }

  public static var ambiguous: GitErrorCode {
    GitErrorCode(GIT_EAMBIGUOUS)!
  }

  public static var generic: GitErrorCode {
    GitErrorCode(GIT_ERROR)!
  }

  public static var notFound: GitErrorCode {
    GitErrorCode(GIT_ENOTFOUND)!
  }

  public static var unbornBranch: GitErrorCode {
    GitErrorCode(GIT_EUNBORNBRANCH)!
  }
}

extension GitError {
  public static var ambiguous: GitErrorCode {
    .ambiguous
  }

  public static var generic: GitErrorCode {
    .generic
  }

  public static var notFound: GitErrorCode {
    .notFound
  }

  public static var unbornBranch: GitErrorCode {
    .unbornBranch
  }
}

public struct GitErrorClass: RawRepresentable {
  public var rawValue: CUnsignedInt

  public init?(rawValue: CUnsignedInt) {
    guard rawValue != GIT_ERROR_NONE.rawValue else { return nil }
    self.rawValue = rawValue
  }

  public init?(rawValue: CInt) {
    self.init(rawValue: CUnsignedInt(rawValue))
  }

  public init?(_ error: git_error_t) {
    self.init(rawValue: error.rawValue)
  }

  public static var system: GitErrorClass {
    GitErrorClass(GIT_ERROR_OS)!
  }
}

extension GitErrorClass: CustomStringConvertible {
  public var description: String {
    "\(GitError.errorDomain) error \(rawValue)"
  }
}

extension git_error_code {
  public static func ~=(pattern: git_error_code, code: CInt) -> Bool {
    pattern.rawValue == code
  }
}

extension GitErrorCode {
  public static func ~=(pattern: GitErrorCode, error: Error) -> Bool {
    let error = error as NSError
    return error.domain == GitError.errorDomain && error.code == pattern.rawValue
  }

  public static func ~=(pattern: GitErrorCode, code: CInt) -> Bool {
    pattern.rawValue == code
  }
}
