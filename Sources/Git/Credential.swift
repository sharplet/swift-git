import Cgit2

public protocol Credential {
  func getCredential(
    _ credential: UnsafeMutablePointer<UnsafeMutablePointer<git_credential>?>!,
    url: UnsafePointer<CChar>!,
    usernameFromURL username: UnsafePointer<CChar>?,
    allowedTypes: CUnsignedInt
  ) -> CInt
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

// MARK: - Plain text credentials

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
  public func getCredential(
    _ credential: UnsafeMutablePointer<UnsafeMutablePointer<git_credential>?>!,
    url: UnsafePointer<CChar>!,
    usernameFromURL: UnsafePointer<CChar>?,
    allowedTypes: CUnsignedInt
  ) -> CInt {
    git_credential_userpass_plaintext_new(credential, username, password)
  }
}

// MARK: - Null credentials

extension Credential where Self == NullCredential {
  public static var none: NullCredential {
    NullCredential()
  }
}

public struct NullCredential: Credential {
  public func getCredential(
    _ credential: UnsafeMutablePointer<UnsafeMutablePointer<git_credential>?>!,
    url: UnsafePointer<CChar>!,
    usernameFromURL username: UnsafePointer<CChar>?,
    allowedTypes: CUnsignedInt
  ) -> CInt {
    1
  }
}
