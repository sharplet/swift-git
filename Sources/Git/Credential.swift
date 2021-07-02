import Cgit2

public protocol Credential {
  func withCallback<Result>(_ body: (CredentialCallback?) throws -> Result) rethrows -> Result
}

public struct CredentialCallback {
  public var callback: git_credential_acquire_cb
  public var payload: UnsafeMutableRawPointer

  public init(
    callback: @escaping git_credential_acquire_cb,
    payload: UnsafeMutableRawPointer
  ) {
    self.callback = callback
    self.payload = payload
  }
}

// MARK: -
// MARK: Plain text credentials

extension Credential where Self == PlainTextCredential {
  public static func plainText(username: String, password: String) -> PlainTextCredential {
    PlainTextCredential(username: username, password: password)
  }
}

public struct PlainTextCredential {
  public var username: String
  public var password: String
}

extension PlainTextCredential: Credential {
  public func withCallback<Result>(_ body: (CredentialCallback?) throws -> Result) rethrows -> Result {
    try username.withCString { username in
      try password.withCString { password in
        var credential = git_credential_userpass_payload(username: username, password: password)
        return try withUnsafeMutablePointer(to: &credential) { credential in
          try body(
            CredentialCallback(
              callback: git_cred_userpass,
              payload: UnsafeMutableRawPointer(credential)
            )
          )
        }
      }
    }
  }
}

// MARK: Null credentials

extension Credential where Self == NullCredential {
  public static var none: NullCredential {
    NullCredential()
  }
}

public struct NullCredential: Credential {
  public func withCallback<Result>(_ body: (CredentialCallback?) throws -> Result) rethrows -> Result {
    try body(nil)
  }
}
