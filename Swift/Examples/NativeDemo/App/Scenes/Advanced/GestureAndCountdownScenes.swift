import UIKit
import LSTPopViewSwift

@MainActor
final class GesturesDemoViewController: DemoSceneViewController {
    private let sweep = UISwitch()
    private let threshold = UISlider()

    init() {
        super.init(sceneTitle: "拖拽、轻扫与滚动", introduction: "卡片同时带滚动列表和顶部拖拽区。先向上滚列表，再从列表内部下拉；回到顶部后，再向下拖动关闭。", learnings: [
            "dragStyle 决定允许方向，dragDistance 决定距离关闭；未达阈值会回弹。",
            "sweepStyle 还需与 dragStyle 方向相交，速度达到 swipeVelocity 才触发轻扫退出。",
            "列表未回顶部时优先滚动；列表顶部时允许弹窗接管向下手势。真实手势协作需要实际拖动观察。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        threshold.minimumValue = 50; threshold.maximumValue = 180; threshold.value = 100
        threshold.accessibilityIdentifier = "advanced.gestures.distance"
        sweep.isOn = true
        sweep.accessibilityIdentifier = "advanced.gestures.sweep"
        addControl(advancedLabel("拖拽关闭阈值：50～180 pt")); addControl(threshold)
        addControl(advancedLabel("允许快速向下轻扫，速度阈值 900 pt/s")); addControl(sweep)
        addAction("打开含滚动列表的卡片", accessibilityID: "advanced.gestures.show") { [weak self] in self?.showScrollable() }
    }

    private func showScrollable() {
        clearScenePopups()
        let content = AdvancedScrollCard()
        guard let popup = makePopup(content: content, position: .bottom, pop: .smoothFromBottom, dismiss: .smoothToBottom) else { return }
        popup.adjustY = -view.safeAreaInsets.bottom
        popup.dragStyle = .y_Positive
        popup.dragDistance = CGFloat(threshold.value)
        popup.dragDismissStyle = .smoothToBottom
        popup.sweepStyle = sweep.isOn ? .y_Positive : .no
        popup.swipeVelocity = 900
        popup.sweepDismissStyle = .smooth
        popup.cornerRadius = 20
        var lastLoggedStep = -1
        popup.panOffsetBlock = { [weak self] offset in
            // 以 40pt 为档位打印，避免每一帧刷日志淹没关键的关闭/回弹事件。
            let step = Int(abs(offset.y) / 40)
            if step != lastLoggedStep { lastLoggedStep = step; self?.log("拖拽位移 y=\(Int(offset.y)) pt。") }
        }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("didDismiss：距离/速度触发或手动关闭已完成。") }
        content.onClose = { [weak popup] in popup?.dismiss() }
        log("向下拖拽阈值 \(Int(threshold.value)) pt；轻扫 \(sweep.isOn ? "开启" : "关闭")。")
        popup.pop()
    }
}

/// 滚动区域与拖拽区是同一内容树中的真实 UIKit 控件。
/// 内容有明确 310×400 frame；scrollView.contentSize 大于可见高度，能够实际滚动。
@MainActor
private final class AdvancedScrollCard: UIView {
    var onClose: (@MainActor () -> Void)?
    private let heading = UILabel()
    private let scroll = UIScrollView()
    private let text = UILabel()
    private let close = UIButton(type: .system)

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 310, height: 400))
        backgroundColor = .secondarySystemBackground
        heading.text = "☰ 从这里向下拖动"
        heading.font = .boldSystemFont(ofSize: 18)
        heading.textAlignment = .center
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.accessibilityIdentifier = "advanced.gestures.scroll"
        text.text = (1...22).map { "第 \($0) 行：先滚动列表，再回到顶部下拉。" }.joined(separator: "\n\n")
        text.numberOfLines = 0
        text.font = .systemFont(ofSize: 15)
        close.setTitle("手动关闭卡片", for: .normal)
        close.accessibilityIdentifier = "advanced.gestures.close"
        close.addAction(UIAction { [weak self] _ in MainActor.assumeIsolated { self?.onClose?() } }, for: .touchUpInside)
        addSubview(heading); addSubview(scroll); addSubview(close); scroll.addSubview(text)
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }
    override func layoutSubviews() {
        super.layoutSubviews()
        heading.frame = CGRect(x: 12, y: 8, width: bounds.width - 24, height: 44)
        scroll.frame = CGRect(x: 16, y: 58, width: bounds.width - 32, height: bounds.height - 116)
        text.frame = CGRect(x: 0, y: 0, width: scroll.bounds.width, height: 1180)
        scroll.contentSize = CGSize(width: scroll.bounds.width, height: 1180)
        close.frame = CGRect(x: 16, y: bounds.height - 50, width: bounds.width - 32, height: 42)
    }
}

@MainActor
final class CountdownDemoViewController: DemoSceneViewController {
    private weak var timedPopup: NativePopup?
    private weak var coveringPopup: NativePopup?

    init() {
        super.init(sceneTitle: "倒计时暂停与恢复", introduction: "先启动 12 秒计时，再加入高优先级遮挡。遮挡期间计时暂停，关闭遮挡后继续剩余时间；也可以随时手动关闭。", learnings: [
            "showTime 从首次显示完成后开始，排队/挂起期间不消耗剩余时间。",
            "生产计时使用单调时钟，修改设备墙上时间不会跳过剩余时长。",
            "didDismiss 会停止 Timer；手动关闭后不应继续收到倒计时。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        addAction("启动 12 秒卡片", accessibilityID: "advanced.countdown.start") { [weak self] in self?.startTimerCard() }
        addAction("高优先级遮挡，暂停计时", accessibilityID: "advanced.countdown.pause") { [weak self] in self?.cover() }
        addAction("关闭遮挡，恢复计时", accessibilityID: "advanced.countdown.resume") { [weak self] in self?.coveringPopup?.dismiss() }
        addAction("手动关闭计时卡片", accessibilityID: "advanced.countdown.stop") { [weak self] in self?.timedPopup?.dismiss(); self?.log("请求手动关闭；观察后续不再产生 tick。") }
    }

    private func startTimerCard() {
        clearScenePopups()
        let card = AdvancedPopupCard(title: "12 秒倒计时", message: "剩余 12 秒。可继续点击本页‘高优先级遮挡’。", height: 190)
        guard let popup = makePopup(content: card, position: .bottom, group: "countdown", priority: 100) else { return }
        timedPopup = popup
        popup.isHideBg = true
        popup.adjustY = -view.safeAreaInsets.bottom - 12
        popup.showTime = 12
        var previousSecond = -1
        popup.popViewCountDownBlock = { [weak self, weak card] _, remaining in
            let second = Int(ceil(remaining))
            card?.body.text = "剩余 \(second) 秒\n遮挡期间不消耗这段剩余时间。"
            if second != previousSecond { previousSecond = second; self?.log("倒计时：\(second) 秒。") }
        }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("计时卡片 didDismiss：计时资源已停止。") }
        card.addButton("手动关闭计时", id: "advanced.countdown.card.close") { [weak popup] in popup?.dismiss() }
        popup.pop()
    }

    private func cover() {
        guard timedPopup != nil, coveringPopup == nil else { log("请先启动计时；同一轮只加入一个遮挡。 "); return }
        let card = AdvancedPopupCard(title: "高优先级遮挡", message: "低优先级计时已挂起。停留几秒后关闭，观察剩余时间继续。", height: 200, color: .systemPurple)
        guard let popup = makePopup(content: card, position: .bottom, group: "countdown", priority: 900) else { return }
        coveringPopup = popup
        popup.isHideBg = true
        popup.adjustY = -view.safeAreaInsets.bottom - 12
        popup.popViewDidDismissBlock = { [weak self] in self?.log("遮挡 didDismiss；随后队列恢复计时卡片。") }
        card.addButton("关闭遮挡并恢复", id: "advanced.countdown.cover.close") { [weak popup] in popup?.dismiss() }
        popup.pop()
        log("已请求高优先级遮挡，后续低窗 tick 应暂停。")
    }
}
