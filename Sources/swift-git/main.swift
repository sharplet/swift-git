import ArgumentParser

struct SwiftGit: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "A simple reimplementation of parts of the git(1) command using swift-git.",
    subcommands: [Clone.self]
  )
}

SwiftGit.main()
