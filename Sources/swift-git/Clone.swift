import ArgumentParser
import Foundation
import Git
import SystemPackage

struct Clone: ParsableCommand {
  static let configuration = CommandConfiguration(abstract: "Clone a repository")

  @Argument var url: URL
  @Argument var path: FilePath?

  func run() throws {
    let path = self.path ?? FilePath(url.lastPathComponent)
    _ = try Repository.clone(to: path, from: url)
  }
}
