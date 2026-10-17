import UIKit
import LSTPopViewSwift

/// 显式限定原生 Swift 类型。即使应用以后同时链接原 Objective-C 库，也不会误用另一套弹窗。
/// 本 Demo 没有依赖或复制 Objective-C 实现，所有展示均调用本地 Swift Package 的公开 API。
typealias NativePopup = LSTPopViewSwift.LSTPopView

/// 目录与独立场景之间唯一需要共享的数据。
///
/// - id: 稳定的、适合自动化定位的场景标识；目录中会直接显示这个值。
/// - title/subtitle: 解释这个场景展示什么，以及值得观察的行为。
/// - makeViewController: 点击目录后才创建页面，避免预先创建内容、计时器或弹窗。
///
/// UIKit 控制器和工厂都属于 MainActor。目录只传递创建动作，不把 UIKit 对象发到后台。
@MainActor
struct DemoScene {
    let id: String
    let title: String
    let subtitle: String
    let makeViewController: @MainActor () -> UIViewController
}
