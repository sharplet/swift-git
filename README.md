# swift-git

Swift bindings for [libgit2][].

```swift
import ArgumentParser
import Git

struct GitExample: ParsableCommand {
  @Argument var url: URL
  @Argument var path: FilePath

  func run() throws {
    let repo = try Repository.clone(from: url, to: path)
    print("Cloned to path '\(repo.path)'.")

    let fileCount = repo.index.entries.count
    print("Repsitory contains \(fileCount) files.")

    let head = try repo.head()
    print("HEAD points to commit \(head.commitID).")

    let branch = try repo.makeBranch("new-branch", switch: true)
    assert(head.commitID == branch.commitID)
  }
}
```

For more examples, see [the swift-git-example project][swift-git-example].

## Installation

swift-git is distributed as a Swift Package. Add it to your Package.swift file
like so:

```swift
let package = Package(
  // ...
  dependencies: [
    .package(url: "https://github.com/sharplet/swift-git", from: "0.1.0"),
  ],
  targets: [
    .target(
      name: "MyTarget",
      dependencies: [
        .product(name: "Git", package: "swift-git"),
      ]
    ),
  ]
)
```

In Xcode, select File > Swift Packages > Add Package Dependency… and follow the
prompts.

## License

swift-git is published under the MIT License.
See [LICENSE](/LICENSE) for details.

swift-git is subject to the terms of the [swift-cgit2 license][] and the
[libgit2 license][]. This means that you may compile and link to these projects
without restriction; however, uses of libgit2 which fall outside the linking
exception are subject to the full terms of the GNU General Public License,
Version 2.

## Alternatives

- For more complete Apple platform support and `Result`-based error handling,
  take a look at [SwiftGit2][].

[SwiftGit2]: https://github.com/SwiftGit2/SwiftGit2
[libgit2 license]: https://github.com/libgit2/libgit2/blob/main/COPYING
[libgit2]: https://libgit2.org/
[swift-cgit2 license]: https://github.com/sharplet/swift-cgit2/blob/main/LICENSE
[swift-git-example]: https://github.com/sharplet/swift-git-example
