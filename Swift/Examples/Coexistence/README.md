# Original Objective-C + native Swift in one app

这个独立 consumer 示例用于验证两版可以在同一个 iOS App 中编译、链接、实例化和展示。它不改原 OC 源文件、原 Example 工程或原 `LSTPopView.podspec`，也不复制项目业务源码。

| 实现 | 真正的来源 | consumer 中的名称 |
| --- | --- | --- |
| Objective-C | CocoaPods 使用仓库根目录现有 podspec，编译 `LSTPopView/Classes/Code` | 在 `LegacyPopupAdapter.m` 中使用原始 `LSTPopView` |
| OC 的计时器 | CocoaPods 实际下载和链接 `LSTTimer 0.2.10` | 原 OC 实现照常引用 |
| Swift | 仓库根目录 `Package.swift` 的 `LSTPopViewSwift` 产品 | `LSTPopViewSwift.LSTPopView` |

`LegacyPopupAdapter` 只是示例 App 的 ObjC 边界，头文件只暴露 UIKit 类型。这样 Swift consumer 不必同时引入两个同名的短类型，也没有给原 OC 类改名。Swift 类使用模块命名空间，测试还会核对真实运行时名称和类对象是否不同。

## 准备和运行

需要 Swift 6.2+ 的 Xcode（包含 iOS Simulator SDK）、Ruby、Bundler，以及可访问 CocoaPods 依赖源的网络。App 和 hosted tests 使用 Swift 6、完整严格并发检查，并以 iOS 16 为最低系统。库自身支持的最低系统由根目录 package 声明，不受此示例的测试要求影响。根目录 Swift package 仅支持 iOS；不要在 macOS 上直接用 `swift test` 代替 iOS consumer 验证。

```bash
cd Swift/Examples/Coexistence
bundle install
bundle exec ./prepare.sh
xcrun simctl list devices available
./run-tests.sh <iOS-Simulator-UDID>
```

`prepare.sh` 只重建本目录下可丢弃的 `CoexistenceApp.xcodeproj`，随后运行 CocoaPods。`Podfile.lock` 应随验证结果保留，以锁定真实 OC 依赖；`Pods`、生成的工程、工作区、DerivedData 和 xcresult 均已忽略。

也可以用已经安装这些 Ruby gems 的环境运行 `./prepare.sh`。请确保 `ruby` 和 `pod` 来自同一套 Ruby 环境；系统 Ruby 没有 `xcodeproj` 时，使用上面的 Bundler 方式。脚本不会自动安装系统软件或修改原项目依赖。

手动打开 `CoexistenceApp.xcworkspace`，选择 `CoexistenceApp` scheme 和 iOS Simulator 即可运行。界面分别提供展示原 OC、展示 Swift、同时展示两版的按钮；点击弹窗背景关闭。这里演示的是两个独立管理器：它们不会跨实现统一优先级或互相清理。

## 自动验证的范围

Hosted XCTest 在真正链接两版的 App 进程里运行，只让 App target 链接一次 Swift package，避免测试 bundle 再链接一份静态产品。consumer helper 使用普通 `import LSTPopViewSwift`，必须通过真正公开的 API 编译。七个 consumer 测试验证：

1. OC 运行时类仍为 `LSTPopView`，Swift 类型拥有不同的模块运行时名称，实际 `LSTTimer` 类已经加载。
2. Swift 可以独立 `pop/dismiss`，生命周期回调正确。
3. 原 OC 可以独立 `pop/dismiss`，生命周期回调正确。
4. 两版可以同时出现在同一父视图中，各自队列计数独立。
5. 清理 Swift 队列保留 OC 弹窗。
6. 清理 OC 队列保留 Swift 弹窗。
7. OC 关闭并释放后，可以重新创建实例再次展示，回调仍有效。

同一个 hosted test target 还直接引用 `Swift/Tests/LSTPopViewSwiftTests/LSTPopViewTests.swift`，运行原生库的 Swift Testing 行为回归，不复制文件。原生测试通过 `@testable import` 检查内部状态；App 的 SceneDelegate 提供它需要的真实 UIWindowScene。测试进程只供这组专用测试使用，不承载业务账号和网络请求。

原 OC 的无动画移除仍通过异步回调完成，且 `didDismiss` 是在 `dealloc` 中发出。adapter 仅在 factory 到 `pop` 之前短暂强持有 OC 弹窗，展示后改为弱引用，由原 manager/视图树管理生命；消费方强持有回调 block，以匹配原库弱 `NSHashTable` 的回调存储方式。关闭后 `popupView` 应为 nil，再次展示会创建新的原 OC 实例。测试等待这一路真实释放回调，不使用固定 sleep 推测完成，也不把 Swift 的移除完成语义强加给 OC。测试不替换原 OC 或 LSTTimer，也不要求两版具有完全相同的排队策略。

结果保存在本目录 `TestResults/*.xcresult`。这是一套可复现的 consumer 检查；实际成功与否以 `xcodebuild` 和 xcresult 的结果为准。模拟器结果不代表真机或全部历史 OC 行为已经验证。
