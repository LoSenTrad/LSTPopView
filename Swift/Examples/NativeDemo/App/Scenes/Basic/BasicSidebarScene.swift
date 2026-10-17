import UIKit
import LSTPopViewSwift

@MainActor
final class BasicSidebarScene: DemoSceneViewController {
    init() {
        super.init(sceneTitle: "左右侧边栏", introduction: "使用同一个内容组件，对比左右锚点与相应方向动画。菜单只更新本页日志，不跳转到真实业务，也不读取账号。", learnings: [
            "左侧栏使用 left + smoothFromLeft，右侧栏使用 right + smoothFromRight。",
            "侧栏高度由本页 bounds 和安全区决定；parent 是本页 view，因此不会创建额外 UIWindow。",
            "菜单选中后可以保持侧栏展示，关闭按钮与背景点击负责结束这一轮 Session。"
        ])
    }

    required init?(coder: NSCoder) { fatalError("This demo creates pages in Swift") }

    override func configureDemo() {
        addAction("打开左侧栏", subtitle: "点击菜单更新内容，再用关闭按钮或背景退出", accessibilityID: "basic.sidebar.left") { [weak self] in self?.showSidebar(left: true) }
        addAction("打开右侧栏", subtitle: "相同内容，切换到右边锚点和方向动画", accessibilityID: "basic.sidebar.right") { [weak self] in self?.showSidebar(left: false) }
    }

    private func showSidebar(left: Bool) {
        let width = min(310, max(190, view.bounds.width * 0.76))
        let height = max(300, view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 24)
        let content = BasicSidebarContent(width: width, height: height, left: left)
        guard let popup = makePopup(content: content, position: left ? .left : .right, pop: left ? .smoothFromLeft : .smoothFromRight, dismiss: left ? .smoothToLeft : .smoothToRight, group: "basic.sidebar") else { return }
        popup.isSingle = true
        popup.isClickBgDismiss = true
        popup.cornerRadius = 18
        popup.adjustX = left ? 12 : -12
        popup.dragStyle = left ? .x_Negative : .x_Positive
        popup.dragDistance = width * 0.4
        content.onSelect = { [weak self] title in self?.log("选择侧栏菜单「\(title)」：只修改演示状态，侧栏继续保持展示。") }
        content.onToggle = { [weak self] on in self?.log("侧栏本地开关：\(on ? "开启" : "关闭")；没有读写系统设置。") }
        content.onClose = { [weak popup] in popup?.dismiss() }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("\(left ? "左" : "右")侧栏已关闭。") }
        popup.pop()
        log("已显示\(left ? "左" : "右")侧栏，也可沿屏幕外侧方向拖动关闭。")
    }
}

@MainActor
private final class BasicSidebarContent: UIView {
    var onSelect: (@MainActor (String) -> Void)?
    var onToggle: (@MainActor (Bool) -> Void)?
    var onClose: (@MainActor () -> Void)?
    private let selection = BasicUI.label("当前：概览", size: 15, bold: true, color: .systemTeal)
    private let localSwitch = UISwitch()

    init(width: CGFloat, height: CGFloat, left: Bool) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 18
        selection.accessibilityIdentifier = "basic.sidebar.selection"
        let header = BasicUI.label(left ? "左侧导航" : "右侧导航", size: 23, bold: true)
        let description = BasicUI.label("所有菜单均是虚构本地演示，点击后可观察选中结果。", size: 14, color: .secondaryLabel)
        let menus = ["概览", "收藏", "本地设置"].enumerated().map { index, title in
            BasicUI.button(title, id: "basic.sidebar.menu.\(index)") { [weak self] in
                self?.selection.text = "当前：\(title)"
                self?.onSelect?(title)
            }
        }
        localSwitch.accessibilityIdentifier = "basic.sidebar.localSwitch"
        localSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        let switchRow = UIStackView(arrangedSubviews: [BasicUI.label("本地演示开关", size: 14), localSwitch])
        switchRow.spacing = 8
        let close = BasicUI.button("关闭侧栏", id: "basic.sidebar.close") { [weak self] in self?.onClose?() }
        let stack = UIStackView(arrangedSubviews: [header, description, selection] + menus + [switchRow])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        // 菜单区域可滚动，关闭按钮固定在底部。横屏/较短页面下不压缩按钮，也不让菜单越界。
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.accessibilityIdentifier = "basic.sidebar.content"
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        close.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scroll)
        addSubview(close)
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            scroll.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            scroll.bottomAnchor.constraint(equalTo: close.topAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            close.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            close.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            close.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) { fatalError("This demo creates content in Swift") }
    @objc private func switchChanged() { onToggle?(localSwitch.isOn) }
}
