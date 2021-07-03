// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "swift-git",
  platforms: [
    .macOS(.v10_13),
    .iOS(.v11),
  ],
  products: [
    .library(name: "Git", targets: ["Git", "swift_git_init"]),
    .executable(name: "swift-git", targets: ["swift-git"]),
  ],
  dependencies: [
    .package(url: "https://github.com/sharplet/swift-cgit2", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.3"),
    .package(url: "https://github.com/apple/swift-system", from: "0.0.2"),
  ],
  targets: [
    .target(name: "Git", dependencies: [.cgit2, .system]),
    .target(name: "swift_git_init", dependencies: [.cgit2]),
    .testTarget(name: "GitTests", dependencies: ["Git"]),
    .executableTarget(name: "swift-git", dependencies: ["Git", .argumentParser, .system]),
  ]
)

extension Target.Dependency {
  static var argumentParser: Target.Dependency {
    .product(name: "ArgumentParser", package: "swift-argument-parser")
  }

  static var cgit2: Target.Dependency {
    .product(name: "Cgit2", package: "swift-cgit2")
  }

  static var system: Target.Dependency {
    .product(name: "SystemPackage", package: "swift-system")
  }
}
