// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "swift-git",
  platforms: [
    .macOS(.v10_13),
    .iOS(.v11),
  ],
  products: [
    .library(name: "Git", targets: ["Git"]),
  ],
  dependencies: [
    .package(url: "https://github.com/sharplet/swift-cgit2", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-system", from: "0.0.2"),
  ],
  targets: [
    .target(
      name: "Git",
      dependencies: [
        .product(name: "Cgit2", package: "swift-cgit2"),
        .product(name: "SystemPackage", package: "swift-system"),
      ]
    ),
    .testTarget(name: "GitTests", dependencies: ["Git"]),
  ]
)
