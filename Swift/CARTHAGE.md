# LSTPopViewSwift with Carthage

The root `LSTPopViewSwift.xcodeproj` contains a shared `LSTPopViewSwift`
dynamic framework scheme. It compiles the same five native Swift source files
as the `LSTPopViewSwift` Swift package product. It does not compile or change
the existing Objective-C CocoaPod, include a demo, or depend on LSTTimer.

Requirements: iOS 15+, a Swift 6.2+ compiler, Swift 6 language mode, and
Carthage 0.38+ with XCFramework support. Use an Xcode installation that provides
that compiler and both the iPhoneOS and iPhoneSimulator SDKs.

For a checkout containing this project, build with:

```sh
carthage build --no-skip-current --use-xcframeworks --platform iOS
```

For an application, add the repository to `Cartfile` at a commit containing this
project, then run `carthage update --use-xcframeworks --platform iOS`. Until a
maintainer publishes a release containing this entry point, pin the actual
commit SHA rather than an existing Objective-C version tag.

Add `Carthage/Build/LSTPopViewSwift.xcframework` to the app target's Frameworks,
Libraries, and Embedded Content section with **Embed & Sign**, then use:

```swift
import UIKit
import LSTPopViewSwift

@MainActor
func showPopup(content: UIView, in parent: UIView) {
    let popup = LSTPopViewSwift.LSTPopView.initWithCustomView(
        content,
        parentView: parent,
        popStyle: .fade,
        dismissStyle: .fade
    )
    popup?.pop()
}
```

Framework builds disable code signing; the consuming app signs its embedded
framework during its own distribution. The scheme supports device and simulator
archives and enables module interfaces. Its presence alone does not establish a
successful Carthage build or a published release.

The sources retain their existing MIT license in [`LICENSE`](LICENSE). See the
[Carthage framework integration guide](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)
for application setup details.
