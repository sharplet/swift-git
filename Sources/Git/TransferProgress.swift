import Cgit2

public struct TransferProgress {
  public var receivedBytes: Int64
  public var receivedObjects: Int
  public var totalObjects: Int

  public init(receivedBytes: Int64 = 0, receivedObjects: Int = 0, totalObjects: Int = 0) {
    self.receivedBytes = receivedBytes
    self.receivedObjects = receivedObjects
    self.totalObjects = totalObjects
  }
}

extension TransferProgress {
  init(_ stats: git_transfer_progress) {
    self.init(
      receivedBytes: Int64(stats.received_bytes),
      receivedObjects: Int(stats.received_objects),
      totalObjects: Int(stats.total_objects)
    )
  }
}
