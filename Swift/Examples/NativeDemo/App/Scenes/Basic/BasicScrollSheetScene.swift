import UIKit
import LSTPopViewSwift

@MainActor
final class BasicScrollSheetScene: DemoSceneViewController {
    init() {
        super.init(sceneTitle: "可滚动底部内容", introduction: "长内容放进 UIScrollView，外层内容 UIView 有明确高度。展开/收起会真正修改内容尺寸，观察库自动重新贴底。", learnings: [
            "滚动视图管理内部 contentSize；弹窗库只管理外层内容的 frame。",
            "修改 content.frame.size 会触发库的尺寸观察，底部锚点随新高度重新计算。",
            "滚动内容与向下拖动关闭可能竞争手势，应在实际产品中测试滚动到顶部后的体验。"
        ])
    }

    required init?(coder: NSCoder) { fatalError("This demo creates pages in Swift") }

    override func configureDemo() {
        addAction("打开可滚动说明面板", subtitle: "滚动 18 段本地示例文字；点击底部按钮改变高度", accessibilityID: "basic.scroll.show") { [weak self] in self?.showSheet(expanded: false) }
        addAction("直接打开展开状态", subtitle: "高度按当前页可用范围计算，不使用全局屏幕尺寸", accessibilityID: "basic.scroll.expanded") { [weak self] in self?.showSheet(expanded: true) }
    }

    private func showSheet(expanded: Bool) {
        let maximum = max(260, view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 32)
        let compactHeight = min(390, maximum)
        let expandedHeight = min(650, maximum)
        let content = BasicScrollableContent(width: BasicUI.width(in: view, maximum: 560, inset: 12), compactHeight: compactHeight, expandedHeight: expandedHeight, expanded: expanded)
        guard let popup = makePopup(content: content, position: .bottom, pop: .smoothFromBottom, dismiss: .smoothToBottom, group: "basic.scroll") else { return }
        popup.isSingle = true
        popup.isClickBgDismiss = true
        popup.adjustY = -max(12, view.safeAreaInsets.bottom)
        popup.dragStyle = .y_Positive
        popup.dragDistance = 120
        content.onClose = { [weak popup] in popup?.dismiss() }
        content.onHeightChanged = { [weak self] height in self?.log("内容高度已改为 \(Int(height)) pt；库根据新尺寸重新贴底。") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("滚动面板已关闭；内容没有网络或文件依赖。") }
        popup.pop()
        log("打开 \(expanded ? "展开" : "紧凑") 面板，可向上滚动长内容。")
    }
}

/// 手工 frame 内容用于展示“谁负责哪一层尺寸”：库摆放 self，本类摆放标题、scrollView 和按钮。
/// 不把 scrollView 的全部内容高度直接变成 popup 高度，否则长文章会超出可见区域。
@MainActor
private final class BasicScrollableContent: UIView {
    var onClose: (@MainActor () -> Void)?
    var onHeightChanged: (@MainActor (CGFloat) -> Void)?
    private let heading = BasicUI.label("滚动说明面板", size: 21, bold: true)
    private let hint = BasicUI.label("先滚动阅读，再切换高度；这 18 段文字来自本地源码。", size: 13, color: .secondaryLabel)
    private let scroll = UIScrollView()
    private var paragraphs = [UILabel]()
    private var toggleButton: UIButton!
    private var closeButton: UIButton!
    private let compactHeight: CGFloat
    private let expandedHeight: CGFloat
    private var expanded: Bool

    init(width: CGFloat, compactHeight: CGFloat, expandedHeight: CGFloat, expanded: Bool) {
        self.compactHeight = compactHeight
        self.expandedHeight = expandedHeight
        self.expanded = expanded
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: expanded ? expandedHeight : compactHeight))
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        scroll.alwaysBounceVertical = true
        scroll.accessibilityIdentifier = "basic.scroll.content"
        scroll.layer.cornerRadius = 12
        scroll.backgroundColor = .tertiarySystemBackground
        for index in 1...18 {
            let paragraph = BasicUI.label("第 \(index) 段 · 外层弹窗保持有限高度，内部滚动承载更长内容。内容更新和按钮交互属于 UIView，队列、遮罩与展示生命周期属于 LSTPopViewSwift。", size: 15)
            paragraph.accessibilityIdentifier = "basic.scroll.paragraph.\(index)"
            scroll.addSubview(paragraph)
            paragraphs.append(paragraph)
        }
        toggleButton = BasicUI.button(expanded ? "收起高度" : "展开高度", id: "basic.scroll.toggle") { [weak self] in self?.toggleHeight() }
        closeButton = BasicUI.button("关闭", id: "basic.scroll.close") { [weak self] in self?.onClose?() }
        [heading, hint, scroll, toggleButton!, closeButton!].forEach(addSubview)
        // 本类用 frame 排版；BasicUI 为普通卡片设置的最小按钮高度仍然成立。
        // 不为自身安装固定高度 Auto Layout 约束，避免后续 frame 改高时产生约束冲突。
    }

    required init?(coder: NSCoder) { fatalError("This demo creates content in Swift") }

    override func layoutSubviews() {
        super.layoutSubviews()
        heading.frame = CGRect(x: 20, y: 20, width: bounds.width - 40, height: 28)
        hint.frame = CGRect(x: 20, y: 56, width: bounds.width - 40, height: 38)
        let footerY = bounds.height - 66
        let buttonWidth = (bounds.width - 50) / 2
        toggleButton.frame = CGRect(x: 20, y: footerY, width: buttonWidth, height: 46)
        closeButton.frame = CGRect(x: 30 + buttonWidth, y: footerY, width: buttonWidth, height: 46)
        scroll.frame = CGRect(x: 16, y: 104, width: bounds.width - 32, height: max(44, footerY - 116))
        var y: CGFloat = 14
        for label in paragraphs {
            let size = label.sizeThatFits(CGSize(width: scroll.bounds.width - 28, height: .greatestFiniteMagnitude))
            label.frame = CGRect(x: 14, y: y, width: scroll.bounds.width - 28, height: ceil(size.height))
            y += ceil(size.height) + 18
        }
        scroll.contentSize = CGSize(width: scroll.bounds.width, height: y)
    }

    private func toggleHeight() {
        expanded.toggle()
        // 库的 frame/bounds 观察会看到尺寸变化，同步更新未受键盘/拖拽影响的定位基准。
        frame.size.height = expanded ? expandedHeight : compactHeight
        toggleButton.setTitle(expanded ? "收起高度" : "展开高度", for: .normal)
        setNeedsLayout()
        layoutIfNeeded()
        onHeightChanged?(frame.height)
    }
}
