import ArgumentParser
import Foundation
import SystemPackage

extension FilePath: ExpressibleByArgument {
  public init?(argument: String) {
    self.init(argument)
  }
}

extension URL: ExpressibleByArgument {
  public init?(argument: String) {
    self.init(string: argument)
  }
}
