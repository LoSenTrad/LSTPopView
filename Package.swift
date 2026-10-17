// swift-tools-version: 6.2
import PackageDescription

// Native Swift is an opt-in product. The existing Objective-C CocoaPod and its
// source glob remain independent; adding this package never compiles the OC files.
let package = Package(
    name: "LSTPopView",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "LSTPopViewSwift", targets: ["LSTPopViewSwift"])
    ],
    targets: [
        .target(name: "LSTPopViewSwift", path: "Swift/Sources/LSTPopViewSwift"),
        .testTarget(
            name: "LSTPopViewSwiftTests",
            dependencies: ["LSTPopViewSwift"],
            path: "Swift/Tests/LSTPopViewSwiftTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
