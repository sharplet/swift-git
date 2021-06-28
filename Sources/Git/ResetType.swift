import Cgit2

public struct ResetType: RawRepresentable {
  public var rawValue: git_reset_t

  public init(rawValue: git_reset_t) {
    self.rawValue = rawValue
  }

  public static let soft = ResetType(rawValue: GIT_RESET_SOFT)
  public static let mixed = ResetType(rawValue: GIT_RESET_MIXED)
  public static let hard = ResetType(rawValue: GIT_RESET_HARD)
}

extension git_reset_t: RawRepresentable {}

extension git_reset_t {
  init(_ type: ResetType) {
    self = type.rawValue
  }
}
