import UIKit
import LSTPopViewSwift

/// 六个常见业务形态分别独立成页，避免把所有配置塞进同一个示例里。
/// 返回的是控制器工厂；点击目录时才创建页面，不预先持有弹窗或输入内容。
@MainActor
enum BasicDemoScenes {
    static var scenes: [DemoScene] {
        [
            DemoScene(id: "basic.confirm", title: "确认框与短提示", subtitle: "确认、取消、背景关闭和自动到期", makeViewController: { BasicConfirmationScene() }),
            DemoScene(id: "basic.share", title: "底部分享面板", subtitle: "网格操作、取消、向下拖动；全部为模拟回调", makeViewController: { BasicShareScene() }),
            DemoScene(id: "basic.form", title: "输入表单与键盘", subtitle: "真实文本输入、校验、键盘避让和关闭", makeViewController: { BasicFormScene() }),
            DemoScene(id: "basic.choice", title: "单选与多选列表", subtitle: "临时选择、确认提交和取消丢弃", makeViewController: { BasicChoiceScene() }),
            DemoScene(id: "basic.scroll", title: "可滚动底部内容", subtitle: "长内容、滚动与展开/收起后的重新贴底", makeViewController: { BasicScrollSheetScene() }),
            DemoScene(id: "basic.sidebar", title: "左右侧边栏", subtitle: "方向动画、菜单交互和局部状态", makeViewController: { BasicSidebarScene() })
        ]
    }
}

/// 本目录共用的最小 UIKit 构件。它只负责内容 UIView，不代替弹窗库安排队列或生命周期。
/// Auto Layout 在卡片内部排版；交给 LSTPopView 之前必须量出明确的 frame.size。
@MainActor
enum BasicUI {
    static func width(in view: UIView, maximum: CGFloat = 420, inset: CGFloat = 24) -> CGFloat {
        max(180, min(maximum, view.bounds.width - inset * 2))
    }

    static func label(_ text: String, size: CGFloat = 15, bold: Bool = false, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    static func button(_ title: String, id: String, destructive: Bool = false, action: @escaping @MainActor () -> Void) -> UIButton {
        let button = BasicActionButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = destructive ? .systemRed.withAlphaComponent(0.10) : .systemTeal.withAlphaComponent(0.12)
        button.tintColor = destructive ? .systemRed : .systemTeal
        button.layer.cornerRadius = 11
        button.accessibilityIdentifier = id
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 46).isActive = true
        button.onTap = action
        return button
    }

    static func row(_ views: [UIView]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: views)
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 10
        return row
    }

    static func card(width: CGFloat, title: String, message: String, controls: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 20
        let heading = label(title, size: 21, bold: true)
        heading.accessibilityTraits.insert(.header)
        let stack = UIStackView(arrangedSubviews: [heading, label(message, color: .secondaryLabel)] + controls)
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22)
        ])
        // 弹窗库接收的是一个有真实尺寸的 UIView；它不会猜测业务内容的 Auto Layout 高度。
        let innerSize = stack.systemLayoutSizeFitting(
            CGSize(width: width - 40, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        card.frame = CGRect(x: 0, y: 0, width: width, height: ceil(innerSize.height) + 44)
        card.layoutIfNeeded()
        return card
    }
}

/// UIControl 的 target-action 由 UIKit 在主线程交付。闭包的 @MainActor 类型也在编译期约束调用方。
/// button 强持有 onTap，所以业务回调需要 weak 捕获 popup/controller/content，避免组成引用环。
@MainActor
private final class BasicActionButton: UIButton {
    var onTap: (@MainActor () -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("This demo creates controls in Swift") }
    @objc private func tapped() { onTap?() }
}
