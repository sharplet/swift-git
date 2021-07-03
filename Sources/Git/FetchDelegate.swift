import Cgit2

final class FetchDelegate {
  let credential: Credential?
  let progressHandler: ((git_transfer_progress) -> Void)?

  init(credential: Credential?, progressHandler: ((git_transfer_progress) -> Void)?) {
    self.credential = credential
    self.progressHandler = progressHandler
  }

  var callbacks: git_remote_callbacks {
    var callbacks = git_remote_callbacks()
    let code = git_remote_init_callbacks(&callbacks, UInt32(GIT_REMOTE_CALLBACKS_VERSION))
    precondition(GIT_OK ~= code)
    callbacks.payload = Unmanaged.passUnretained(self).toOpaque()

    if credential != nil {
      callbacks.credentials = FetchDelegate.credentialsCallback
    }

    if progressHandler != nil {
      callbacks.transfer_progress = FetchDelegate.transferProgressCallback
    }

    return callbacks
  }
}

private extension FetchDelegate {
  static func fromPayload(_ payload: UnsafeMutableRawPointer!) -> FetchDelegate {
    Unmanaged.fromOpaque(payload).takeUnretainedValue()
  }

  func nextCredential(
    _ credential: UnsafeMutablePointer<UnsafeMutablePointer<git_credential>?>!,
    url: UnsafePointer<CChar>!,
    usernameFromURL username: UnsafePointer<CChar>?,
    allowedTypes: CUnsignedInt
  ) -> CInt {
    self.credential?.getCredential(credential, url: url, usernameFromURL: username, allowedTypes: allowedTypes) ?? 1
  }

  func updateTransferProgress(with stats: UnsafePointer<git_transfer_progress>) {
    progressHandler?(stats.pointee)
  }
}

extension FetchDelegate {
  static let credentialsCallback: git_credential_acquire_cb = { credential, url, usernameFromURL, allowedTypes, payload in
    FetchDelegate.fromPayload(payload).nextCredential(
      credential,
      url: url,
      usernameFromURL: usernameFromURL,
      allowedTypes: allowedTypes
    )
  }

  static let transferProgressCallback: git_transfer_progress_cb = { stats, payload in
    if let stats = stats {
      FetchDelegate.fromPayload(payload).updateTransferProgress(with: stats)
    }
    return 0
  }
}
