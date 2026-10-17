import UIKit
import LSTPopViewSwift

/// 进阶场景的唯一目录。每一项创建独立控制器，避免把队列、手势和生命周期状态混在首页。
/// 这些 consumer 文件只通过公开 API 使用原生模块，没有 @testable import 或对内部状态的伪造。
@MainActor
enum AdvancedDemoScenes {
    static var scenes: [DemoScene] {
        [
            DemoScene(id: "advanced.queue", title: "优先级队列与分组", subtitle: "高低优先级、同级新窗、group 隔离", makeViewController: { QueueDemoViewController() }),
            DemoScene(id: "advanced.modes", title: "堆叠与单显", subtitle: "比较 stack 与 single 的真实展示规则", makeViewController: { ModesDemoViewController() }),
            DemoScene(id: "advanced.anchors", title: "九宫格定位与偏移", subtitle: "九种锚点、X/Y 校准与安全区", makeViewController: { AnchorsDemoViewController() }),
            DemoScene(id: "advanced.animation", title: "弹入与退出动画", subtitle: "分别选择样式，观察真实生命周期", makeViewController: { AnimationDemoViewController() }),
            DemoScene(id: "advanced.gestures", title: "拖拽、轻扫与滚动", subtitle: "距离阈值、速度阈值和列表交接", makeViewController: { GesturesDemoViewController() }),
            DemoScene(id: "advanced.countdown", title: "倒计时暂停与恢复", subtitle: "优先级挂起、剩余时间与手动关闭", makeViewController: { CountdownDemoViewController() }),
            DemoScene(id: "advanced.dynamic", title: "动态内容与圆角", subtitle: "修改实际内容 frame，观察布局重算", makeViewController: { DynamicContentDemoViewController() }),
            DemoScene(id: "advanced.lifecycle", title: "生命周期与弱多代理", subtitle: "代理、Block 顺序及代理释放", makeViewController: { LifecycleDemoViewController() }),
            DemoScene(id: "advanced.scope", title: "宿主与上下文失效", subtitle: "只替换本页模拟宿主，不操作真实账号", makeViewController: { ScopeDemoViewController() }),
            DemoScene(id: "advanced.accessibility", title: "透明背景与辅助功能", subtitle: "背景穿透、模态焦点和系统动画偏好", makeViewController: { AccessibilityDemoViewController() })
        ]
    }
}

/// 为教学示例提供有确定 frame 的内容，不依赖生产业务 View 或约束。
/// 弹窗拥有 card，card 的按钮闭包只弱引用 popup/控制器，避免形成 popup→card→popup 环。
@MainActor
final class AdvancedPopupCard: UIView {
    let heading = UILabel()
    let body = UILabel()
    private var actionButtons = [UIButton]()

    init(title: String, message: String, width: CGFloat = 290, height: CGFloat = 220, color: UIColor = .systemTeal) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        backgroundColor = .secondarySystemBackground
        layer.borderColor = color.cgColor
        layer.borderWidth = 2
        heading.text = title
        heading.font = .boldSystemFont(ofSize: 18)
        heading.numberOfLines = 2
        heading.textColor = color
        body.text = message
        body.font = .systemFont(ofSize: 14)
        body.numberOfLines = 0
        addSubview(heading)
        addSubview(body)
        accessibilityIdentifier = "advanced.popup.card"
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError("示例卡片只使用代码创建") }

    func addButton(_ title: String, id: String? = nil, action: @escaping @MainActor () -> Void) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.accessibilityIdentifier = id
        // UIKit 按钮事件来自主线程；同步确认隔离，保持按钮→pop/dismiss→日志的原始顺序。
        button.addAction(UIAction { _ in MainActor.assumeIsolated { action() } }, for: .touchUpInside)
        addSubview(button)
        actionButtons.append(button)
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        heading.frame = CGRect(x: 16, y: 14, width: bounds.width - 32, height: 46)
        let controlsHeight = CGFloat(actionButtons.count) * 42
        body.frame = CGRect(x: 16, y: 62, width: bounds.width - 32, height: max(20, bounds.height - 76 - controlsHeight))
        for (index, button) in actionButtons.enumerated() {
            button.frame = CGRect(x: 16, y: bounds.height - controlsHeight - 8 + CGFloat(index) * 42, width: bounds.width - 32, height: 40)
        }
    }
}

@MainActor
func advancedLabel(_ text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .preferredFont(forTextStyle: .footnote)
    label.numberOfLines = 0
    return label
}
