import UIKit
import LSTPopViewSwift

/// 每个原生 Swift 场景共用的教学页面。
///
/// 页面始终按“场景说明 → 观察要点 → 操作 → 事件日志”排列；场景子类只需重写
/// configureDemo()，添加按钮、输入框或分段控件，并通过 makePopup 创建真实弹窗。
/// 这种组织方式让使用者可以先理解行为，再操作并核对事件，不需要先读整个 Demo。
///
/// 该基类刻意不调用 removeAllPopView / invalidateAllScopes：演示页只是一个宿主，
/// 离开页面时只清理 parentView === self.view 的弹窗，不应关闭其它页面或 scene 的弹窗。
@MainActor
class DemoSceneViewController: UIViewController {
    /// 由目录在 push 前设置。对应目录行里的 ID，也用于生成页面 accessibilityIdentifier。
    var demoSceneID: String?

    private let sceneTitle: String
    private let introduction: String
    private let learnings: [String]
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let actionsStack = UIStackView()
    private let logTextView = UITextView()
    private let logCountLabel = UILabel()
    private var actionCount = 0
    private var logLines: [String] = []
    private var logSequence = 0
    private let maximumLogLines = 200
    /// 清理过程可能调用业务生命周期回调；禁止这些回调通过本页工厂再创建一轮弹窗。
    /// 普通按钮点击不受影响，清理完成后仍可以继续在当前页面演示。
    private var isClearingScene = false
    private let logDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    init(sceneTitle: String, introduction: String, learnings: [String]) {
        self.sceneTitle = sceneTitle
        self.introduction = introduction
        self.learnings = learnings
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("NativeDemo 使用纯代码页面，请通过场景工厂创建。")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = sceneTitle
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        view.accessibilityIdentifier = "nativeDemo.screen.\(demoSceneID ?? sceneTitle)"
        configurePageLayout()
        configureDemo()
        log("页面就绪；点击操作按钮开始，弹窗关闭后可再次尝试。")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 返回目录、切换页面时结束当前演示，防止等待队列、通知或倒计时遗留到下个场景。
        // 使用当前 UIView 宿主过滤，而不是全局失效，保证其它窗口和场景仍可正常工作。
        clearScenePopups()
    }

    /// 子类的唯一配置入口。此时操作容器和日志都已创建，可以安全调用 addAction/addControl。
    /// 子类应该在这里配置交互；不要在目录初始化时提前 pop()。
    func configureDemo() {}

    /// 添加一个可直接点击的演示动作。subtitle 放具体的观察提示，不隐藏在代码注释中。
    ///
    /// accessibilityID 可以传入稳定英文标识，供 UI 检查直接定位；省略时使用本页内序号。
    /// UIAction 在 UIKit 的主线程边界同步恢复 MainActor，不异步改变按钮与弹窗事件的顺序。
    func addAction(
        _ title: String,
        subtitle: String? = nil,
        accessibilityID: String? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        actionCount += 1
        var configuration = UIButton.Configuration.tinted()
        configuration.title = title
        configuration.subtitle = subtitle
        configuration.titleAlignment = .leading
        configuration.baseForegroundColor = .systemTeal
        configuration.baseBackgroundColor = UIColor.systemTeal.withAlphaComponent(0.09)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        configuration.cornerStyle = .medium
        let button = UIButton(configuration: configuration, primaryAction: UIAction { _ in
            MainActor.assumeIsolated { action() }
        })
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.numberOfLines = 0
        button.accessibilityIdentifier = accessibilityID ?? "nativeDemo.action.\(actionCount)"
        button.accessibilityHint = subtitle
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
        actionsStack.addArrangedSubview(button)
    }

    /// 添加输入框、分段控件、开关或自定义说明视图；容器会管理水平布局和上下间距。
    /// 控件本身可保留自己的 target/action、delegate 或 UIAction，不需要依赖第三方布局库。
    func addControl(_ control: UIView) {
        actionsStack.addArrangedSubview(control)
    }

    /// 将真实生命周期、手势、队列或计时事件追加到页面日志。
    /// 最多保留最近 200 条；长期点击或高频倒计时不会让演示应用的内存和日志视图无限增长。
    func log(_ message: String) {
        logSequence += 1
        let timestamp = logDateFormatter.string(from: Date())
        logLines.append("\(logSequence). [\(timestamp)] \(message)")
        if logLines.count > maximumLogLines {
            logLines.removeFirst(logLines.count - maximumLogLines)
        }
        refreshLog()
    }

    /// 工厂显式使用当前页面 view，不依赖全局 keyWindow，也不会把弹窗显示到其它 scene。
    ///
    /// 默认提供通用生命周期日志和点击背景关闭；子类可以继续修改配置，或覆盖某个回调
    /// 展示专门场景。回调只弱引用控制器，避免“控制器 → 弹窗 → 闭包 → 控制器”的引用环。
    /// 本方法只创建和配置，不调用 pop()；因此可以先设置 group/priority/手势再正式入队。
    func makePopup(
        content: UIView,
        position: LSTHemStyle = .center,
        pop: LSTPopStyle = .fade,
        dismiss: LSTDismissStyle = .fade,
        group: String? = nil,
        priority: CGFloat = 0
    ) -> NativePopup? {
        guard !isClearingScene else { return nil }
        guard let popup = NativePopup.initWithCustomView(
            content, parentView: view, popStyle: pop, dismissStyle: dismiss
        ) else {
            log("创建失败：未找到有效的当前页面宿主。")
            return nil
        }
        popup.hemStyle = position
        popup.groupId = group
        popup.priority = priority
        popup.isClickBgDismiss = true
        popup.accessibilityIdentifier = "nativeDemo.popup.\(demoSceneID ?? sceneTitle)"
        popup.popViewWillPopBlock = { [weak self] in self?.log("willPop：开始展示。") }
        popup.popViewDidPopBlock = { [weak self] in self?.log("didPop：展示完成，内容可交互。") }
        popup.popViewWillDismissBlock = { [weak self] in self?.log("willDismiss：开始关闭。") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("didDismiss：已移出视图并解除本轮管理持有。") }
        return popup
    }

    /// 仅关闭本页宿主下已经登记的窗口。使用 .no 立即完成移除，离开页面后不会留下动画。
    /// 局部快照包含可见和等待项；清理锁防止生命周期回调通过本页工厂继续制造新对象。
    /// 点击“清空日志”完全不会调用这里，让日志操作与正在演示的弹窗生命周期互不干扰。
    func clearScenePopups() {
        guard isViewLoaded, !isClearingScene else { return }
        isClearingScene = true
        defer { isClearingScene = false }
        view.endEditing(true)
        let popups = NativePopup.getAllPopView(forParentView: view)
        popups.forEach { $0.dismiss(with: .no, duration: 0) }
        if !popups.isEmpty { log("已清理本页 \(popups.count) 个弹窗；其它宿主不受影响。") }
    }

    // MARK: 页面公共布局

    private func configurePageLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        let introductionStack = UIStackView(arrangedSubviews: [
            heading("场景说明"), textLabel(introduction)
        ])
        introductionStack.axis = .vertical
        introductionStack.spacing = 10
        contentStack.addArrangedSubview(card(containing: introductionStack))

        if !learnings.isEmpty {
            let knowledgeStack = UIStackView()
            knowledgeStack.axis = .vertical
            knowledgeStack.spacing = 10
            knowledgeStack.addArrangedSubview(heading("观察要点"))
            for (index, learning) in learnings.enumerated() {
                knowledgeStack.addArrangedSubview(textLabel("\(index + 1). \(learning)"))
            }
            contentStack.addArrangedSubview(card(containing: knowledgeStack))
        }

        actionsStack.axis = .vertical
        actionsStack.spacing = 12
        let actionSection = UIStackView(arrangedSubviews: [heading("操作区"), actionsStack])
        actionSection.axis = .vertical
        actionSection.spacing = 12
        contentStack.addArrangedSubview(card(containing: actionSection))
        configureLogSection()
    }

    private func configureLogSection() {
        var clearConfiguration = UIButton.Configuration.plain()
        clearConfiguration.title = "清空日志"
        clearConfiguration.baseForegroundColor = .systemTeal
        let clearButton = UIButton(configuration: clearConfiguration, primaryAction: UIAction { [weak self] _ in
            MainActor.assumeIsolated {
                self?.logLines.removeAll()
                self?.logSequence = 0
                self?.refreshLog()
            }
        })
        clearButton.accessibilityIdentifier = "nativeDemo.clearLog"
        clearButton.accessibilityHint = "只清空文字记录，不关闭当前弹窗。"
        let header = UIStackView(arrangedSubviews: [heading("事件日志"), UIView(), clearButton])
        header.axis = .horizontal
        header.alignment = .center
        logCountLabel.font = .preferredFont(forTextStyle: .caption1)
        logCountLabel.textColor = .secondaryLabel
        logCountLabel.accessibilityIdentifier = "nativeDemo.logCount"
        logTextView.isEditable = false
        logTextView.isSelectable = true
        logTextView.backgroundColor = .clear
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.adjustsFontForContentSizeCategory = true
        logTextView.textColor = .label
        logTextView.textContainerInset = .zero
        logTextView.textContainer.lineFragmentPadding = 0
        logTextView.accessibilityIdentifier = "nativeDemo.eventLog"
        logTextView.accessibilityLabel = "事件日志"
        logTextView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        let stack = UIStackView(arrangedSubviews: [header, logCountLabel, logTextView])
        stack.axis = .vertical
        stack.spacing = 8
        contentStack.addArrangedSubview(card(containing: stack))
        refreshLog()
    }

    private func refreshLog() {
        logCountLabel.text = "最近 \(logLines.count) / \(maximumLogLines) 条 · 页面离开时仅清理本页弹窗"
        logTextView.text = logLines.isEmpty ? "暂无事件。点击操作按钮后查看真实回调。" : logLines.joined(separator: "\n")
        let end = max(0, logTextView.text.utf16.count - 1)
        logTextView.scrollRangeToVisible(NSRange(location: end, length: 0))
    }

    private func heading(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }

    private func textLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    /// 所有公共模块使用同一套系统动态颜色和内边距，同时兼容深色模式与较大字体。
    private func card(containing content: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        return container
    }
}
