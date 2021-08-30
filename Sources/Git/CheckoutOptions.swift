import Cgit2

public struct CheckoutOptions {
  public var strategy: Strategy

  public init(strategy: Strategy = []) {
    self.strategy = strategy
  }

  public static var `default`: CheckoutOptions {
    CheckoutOptions(strategy: .safe)
  }
}

extension CheckoutOptions {
  public struct Strategy: OptionSet {
    public var rawValue: CUnsignedInt

    public init(rawValue: CUnsignedInt) {
      self.rawValue = rawValue
    }

    public init(_ strategy: git_checkout_strategy_t) {
      self.init(rawValue: strategy.rawValue)
    }

    public static var safe: Strategy {
      Strategy(GIT_CHECKOUT_SAFE)
    }

    public static var force: Strategy {
      Strategy(GIT_CHECKOUT_FORCE)
    }
  }
}

extension git_checkout_options {
  public init(_ options: CheckoutOptions) throws {
    self.init()
    try GitError.check(
      git_checkout_options_init(&self, CUnsignedInt(GIT_CHECKOUT_OPTIONS_VERSION)),
      operation: "git_checkout_options_init"
    )
    checkout_strategy = options.strategy.rawValue
  }
}
