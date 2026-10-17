# LSTPopView 原生 Swift 场景 Demo

这是面向使用和学习的独立 UIKit App，按常用场景展示 `LSTPopViewSwift`，并为配置、回调、队列、内存和系统行为提供详细中文注释。原 Objective-C Demo 继续保留在仓库根目录的 `Example/`；两者不是替换关系。

## 模拟器实拍

以下为实际运行的目录、底部面板和输入表单。分享和保存按钮只执行本地演示回调；截图不是设计稿。

| 场景目录 | 底部分享面板 | 输入表单 |
|---|---|---|
| <img src="Screenshots/catalog.png" width="240" alt="Swift 场景目录" /> | <img src="Screenshots/share.png" width="240" alt="本地模拟分享面板" /> | <img src="Screenshots/form.png" width="240" alt="收起键盘后保留草稿的表单" /> |

## 打开和运行

1. 使用包含 Swift 6.2+ 编译器的 Xcode（Xcode 26+）。
2. 打开本目录的 `NativeSwiftDemo.xcodeproj`。
3. 选择 `NativeSwiftDemo` Scheme 和可用的 iPhone Simulator，运行。

Demo 使用仓库根目录的本地 Swift Package 产品 `LSTPopViewSwift`，不需要 CocoaPods、第三方 UI 库、账号或后端。库和 Demo 的部署下限为 iOS 15；是否在某个具体旧系统运行通过，需要以实际运行结果为准。

```bash
xcodebuild build \
  -project Swift/Examples/NativeDemo/NativeSwiftDemo.xcodeproj \
  -scheme NativeSwiftDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

需要真机运行时，在 Xcode 中选择自己的签名团队和设备。仓库不会包含个人签名配置或凭据。

## 页面组织

首页分为“常用业务场景”和“队列、交互与生命周期”两组。进入页面后，先阅读场景说明和知识点，再点击操作按钮；事件日志用于观察点击结果、展示/关闭回调、队列恢复和对象失效。返回目录时，页面会清理属于自己的演示弹窗，避免各页互相影响。

| 场景 | 可以操作什么 | 重点阅读什么 |
|---|---|---|
| 确认框与短提示 | 展示确认框、取消/确认、点击遮罩、短提示 | 自定义内容与容器职责、按钮回调、`weak` 捕获、自动关闭 |
| 底部分享面板 | 选择模拟分享渠道或关闭 | `.bottom`、底部进出动画、圆角、返回选择结果；不调用真实分享 SDK |
| 输入表单 | 输入演示文本、切换焦点、提交/取消、收起键盘 | 内容尺寸、键盘避让、键盘事件、输入结果和关闭时序 |
| 单选与多选列表 | 点击条目、改变选择、确认结果 | 自定义列表管理选择状态，弹窗只管理展示；多选结果通过回调返回 |
| 可滚动底部内容 | 滚动长内容、改变高度、关闭面板 | 滚动视图边界、面板高度与屏幕限制、业务负责计算尺寸 |
| 左右侧边栏 | 从左/右展示菜单、选择菜单项 | 对齐方式与动画方向分开配置、遮罩关闭、内容区域响应 |
| 优先级队列 | 低/高/同优先级入队、关闭当前项、查看恢复 | `priority`、按宿主和 `groupId` 隔离、每轮 Session 快照 |
| 堆叠与单例替换 | 对照普通队列、`isStack`、`isSingle` | 同组弹窗如何共存/替换，等待者在当前项移除后的恢复 |
| 九宫格定位 | 切换九种锚点并调节偏移 | `hemStyle` 与 `adjustX/adjustY`，基于父容器本地坐标定位 |
| 动画对照 | 选择弹入/退出样式并展示 | 动画与位置独立、默认时长、减少动态效果可能改变运动样式 |
| 拖拽、轻扫与滚动 | 拖动、回弹、达到距离关闭、快速轻扫 | `dragStyle`、`dragDistance`、`sweepStyle`、速度阈值与滚动协作 |
| 倒计时与暂停恢复 | 开始计时、手动关闭、被高优先级挂起后恢复 | 单调时钟、剩余时长、关闭后停止资源、倒计时回调 |
| 动态内容与圆角 | 增减内容高度、观察位置与遮罩更新 | `frame/bounds` 变化观察、自动重新定位、圆角 mask 适配 |
| 生命周期与弱多代理 | 展示/关闭、添加/移除代理、查看事件顺序 | `will/did` 与 Block 顺序、弱代理、回调重入、对象释放 |
| 宿主释放与失效 | 在局部容器展示/排队，再释放宿主 | 弱宿主、可见与等待对象回收；账号/Scene 失效接口的真实接入位置 |
| 背景穿透与辅助功能 | 对比模态遮罩和透明穿透，点击底层按钮 | `isHideBg` 对命中与可访问性模态的影响、系统动画/焦点策略 |

所有分享、提交、菜单选择等操作都只在本地更新演示结果和日志，不发送网络请求，也不保存个人资料。辅助功能页面用于解释和观察系统策略，不会替用户打开 VoiceOver 或修改系统设置。

## 建议阅读顺序

1. `App/DemoCatalogViewController.swift`：场景目录和导航。
2. `App/Support/`：统一场景页面、操作区、日志和局部清理。
3. `App/Scenes/Basic/`：常用业务场景，自定义内容如何返回结果。
4. `App/Scenes/Advanced/`：队列、手势、动态布局和生命周期。
5. `../../Sources/LSTPopViewSwift/`：库内部实现，先看 Types、Session 和 Manager，再看 UIKit 展示层。

Demo 通过普通 `import LSTPopViewSwift` 使用公开接口，没有使用 `@testable` 或访问内部状态机。每个页面的操作按钮带稳定的 `accessibilityIdentifier`，方便继续编写 UI 自动化。

## 常用参数速查

下面是库本身的默认值。Demo 的公共工厂会主动打开“点击背景关闭”，并添加弱引用生命周期日志；场景页还会按教学目标修改动画、位置和分组，不能把 Demo 配置误认为库的全部默认值。

| 参数 | 库默认值 / 规则 | 常见用途 |
|---|---|---|
| `hemStyle` | `.center`，共九种锚点 | 居中提示、底部面板、左右侧栏 |
| `adjustX` / `adjustY` | `0`；基于锚点追加本地坐标偏移 | 小菜单、错位堆叠、避免固定工具区 |
| `bgAlpha` / `bgColor` | `0.25` / 黑色 | 配置遮罩视觉；透明度为零不等于触摸穿透 |
| `isHideBg` | `false` | 需要点击底层控件时使用真正的背景穿透 |
| `isClickBgDismiss` | `false` | 允许点击遮罩关闭；重要确认可保持关闭 |
| `cornerRadius` / `rectCorners` | `0` / 所有角 | 居中卡片全圆角、底部面板只处理上方圆角 |
| `isAvoidKeyboard` / `avoidKeyboardSpace` | `true` / `10` 点 | 输入框被键盘遮挡时避让 |
| `groupId` | `nil`；分组同时包含宿主身份 | 同页不同业务队列互不影响 |
| `priority` | `0`，有效范围 `0...1000` | 高优先级抢占；每轮入队固定快照 |
| `isStack` / `isSingle` | 都为 `false` | 选择堆叠共存或同组替换；不要同时开启两种意图 |
| `showTime` | `0`，不开启自动关闭 | 短提示、倒计时弹窗；挂起时保留剩余时间 |
| `dragStyle` / `sweepStyle` | `.no` | 明确允许方向后再演示拖拽、轻扫 |
| `dragDistance` | `0`，拖动后回弹 | 正值代表拖到指定距离后关闭 |
| `swipeVelocity` | `1000` | 快速轻扫关闭的速度阈值 |

动画由工厂参数或公开属性设置，弹入/退出样式可以分别选择。只传 `customView` 的兼容工厂默认无动画；本 Demo 公共工厂默认使用淡入淡出，因此场景源码会把具体动画选择明确写出。系统减少动态效果或交叉淡化偏好可能将运动动画替换为淡化，不能仅凭界面效果判断枚举配置没有生效。

## 自己接入时的关键规则

### 显式指定父容器

```swift
import UIKit
import LSTPopViewSwift

@MainActor
func showExample(in parent: UIView) {
    let content = UILabel(frame: CGRect(x: 0, y: 0, width: 280, height: 150))
    content.text = "示例内容"
    content.textAlignment = .center
    content.backgroundColor = .systemBackground

    guard let popup = LSTPopViewSwift.LSTPopView.initWithCustomView(
        content,
        parentView: parent,
        popStyle: .scale,
        dismissStyle: .fade
    ) else { return }

    popup.cornerRadius = 16
    popup.isClickBgDismiss = true
    popup.pop()
}
```

普通页面可传 `view`；窗口级弹窗可传所属 `UIWindow`。多 Scene 项目应传正确 Scene 的容器，不要从 `connectedScenes` 随意取第一个。工厂未指定父容器、又无法唯一确定前台窗口时会返回 `nil`，调用方应正常处理。

### 内容先确定尺寸，再交给弹窗展示

库不会替业务决定内容宽高。可以使用手工 `frame`，也可以先用 Auto Layout 的 `systemLayoutSizeFitting` 算出尺寸，再设置内容的 `frame`。动态内容页展示了显示后改变尺寸的方式；内部会重新定位并更新圆角，不会擅自覆盖内容自己的业务约束。

### 界面状态通过 MainActor 访问

公开弹窗 API 受 `@MainActor` 隔离，UIKit 页面里的操作沿用这一隔离。从其他异步上下文调用时需要正确切换隔离；不要把网络、图片解码、大量计算等同步耗时工作放进主 Actor。MainActor 负责串行访问，生命周期回调重入仍由库内事务和会话校验处理。

### 让所有权保持单向

显示/排队期间，管理器的 Session 会持有弹窗，弹窗会持有内容。业务回调捕获控制器、内容视图反向引用弹窗时，使用 `weak`。在 `pop()` 前保留工厂返回的局部强引用，配置完成后再入队；不要把尚未入队的实例直接赋给唯一的弱属性。

### 按生命周期选择清理接口

- `dismiss()`：按配置动画关闭当前弹窗。
- `removeAllPopView()`：普通清场，清场结束后允许明确重新展示旧对象；作用于这个 Swift 模块的整个队列。
- `invalidateAllScopes()`：账号退出或根界面切换前，永久撤销旧创建上下文；其后需要创建新弹窗。
- `invalidatePopViews(in: scene)`：Scene 断开时撤销该 Scene 的旧上下文。

场景页退出时只清理属于当前页的弹窗。局部宿主页通过释放自己的 UIView 演示清理，不会实际退出账号、切换业务根界面或删除任何数据。真正接入账号切换时，应在替换根界面之前调用对应失效接口。

## 与原 OC Demo 和共存测试的关系

- 原 OC Demo：`Example/LSTPopView.xcworkspace`，继续使用原 OC 源码、Pod 与 LSTTimer。
- 本 NativeDemo：使用独立原生 Swift 模块，重点演示常用场景与详细用法。
- `../Coexistence/`：同一个 App 同时链接原 OC 和 Swift，验证类名和队列隔离；不要求两版所有内部生命周期完全一致。

OC 的 `didDismiss` 包含原析构回调语义，Swift 的回调在真实移除完成时发出。需要同时集成时按模块限定同名 Swift 类型，两版清理接口不会相互关闭对方的队列。

## 验证范围

库的参数化行为测试位于 `Swift/Tests/`，共存 consumer 的命令见 `../Coexistence/README.md`。示例工程能构建、模拟器某条交互通过、全部场景人工检查、真机验证，是不同的证据；请以实际执行结果为准。Xcode 工程已提交，只有需要重新扫描源文件时才运行 `generate-project.rb`，普通使用无需 Ruby。
