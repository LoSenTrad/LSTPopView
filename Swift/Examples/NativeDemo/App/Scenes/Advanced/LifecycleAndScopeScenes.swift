import UIKit
import LSTPopViewSwift

/// 真实多代理接收者。控制器持有代理，popup 内部只弱保存；释放控制器持有后代理即可消失。
/// sink 只弱捕获页面，避免 page→probe→sink→page 的引用环。
@MainActor
private final class AdvancedLifecycleProbe: LSTPopViewProtocol {
    let name: String
    private let sink: @MainActor (String) -> Void
    init(name: String, sink: @escaping @MainActor (String) -> Void) { self.name = name; self.sink = sink }
    private func emit(_ event: String) { sink("代理 \(name)：\(event)") }
    func lst_PopViewBgClick(for popView: NativePopup) { emit("bgClick") }
    func lst_PopViewBgLongPress(for popView: NativePopup) { emit("bgLongPress") }
    func lst_PopViewWillPop(for popView: NativePopup) { emit("willPop") }
    func lst_PopViewDidPop(for popView: NativePopup) { emit("didPop") }
    func lst_PopViewWillDismiss(for popView: NativePopup) { emit("willDismiss") }
    func lst_PopViewDidDismiss(for popView: NativePopup) { emit("didDismiss") }
    func lst_PopViewCountDownFinish(for popView: NativePopup) { emit("countDownFinish") }
}

@MainActor
final class LifecycleDemoViewController: DemoSceneViewController {
    private var first: AdvancedLifecycleProbe?
    private var second: AdvancedLifecycleProbe?
    private weak var observedSecond: AdvancedLifecycleProbe?
    private weak var current: NativePopup?
    /// 只记录本轮是否仍把 A 注册给 popup；页面持有 A 并不代表 popup 仍订阅它。
    private var isFirstAttached = false

    init() {
        super.init(sceneTitle: "生命周期与弱多代理", introduction: "同一弹窗依次设置两个 delegate，实际进入弱多代理池。卡片内释放 B，再关闭，检查日志中剩下哪些通知。", learnings: [
            "delegate 多次赋值会加入不同对象，不会强持有代理。业务自己决定代理生命。",
            "每个生命周期先通知代理，再调用同类 Block；日志使用同一个页面观察顺序。",
            "代理释放/移除后不应再接收后续事件；didDismiss 代表 Swift 当前轮移除完成，不要求对象 deinit。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        addAction("创建 A、B 两个代理并展示", accessibilityID: "advanced.lifecycle.show") { [weak self] in self?.showProbe() }
        addAction("释放业务持有的 B", accessibilityID: "advanced.lifecycle.releaseB") { [weak self] in self?.releaseSecond() }
        addAction("从 popup 移除代理 A", accessibilityID: "advanced.lifecycle.removeA") { [weak self] in
            guard let self else { return }
            self.removeFirst(from: self.current)
        }
    }

    private func removeFirst(from popup: NativePopup?) {
        guard let popup, popup === current, popup.superview != nil,
              popup.isPresentationContextValid, let first else {
            log("没有本页正在展示且有效的弹窗；请先打开卡片，并使用卡片内的‘移除 A’按钮。")
            return
        }
        guard isFirstAttached else { log("本轮 A 已移除，无需重复操作。"); return }
        popup.remove(forDelegate: first)
        isFirstAttached = false
        log("已显式移除 A；页面仍持有 A，但本轮 popup 不再通知它。关闭后只应看到仍存活的代理及 Block。")
    }

    private func releaseSecond() {
        second = nil
        log("业务已释放 B；weak B == nil：\(observedSecond == nil)。关闭后检查 B 不再收到 dismiss。")
    }

    private func showProbe() {
        clearScenePopups()
        first = AdvancedLifecycleProbe(name: "A") { [weak self] in self?.log($0) }
        second = AdvancedLifecycleProbe(name: "B") { [weak self] in self?.log($0) }
        observedSecond = second
        let card = AdvancedPopupCard(title: "观察代理 → Block", message: "卡片内可释放 B、移除 A，再关闭。点背景记录 bgClick，不会自动关闭。", height: 320)
        guard let popup = makePopup(content: card, pop: .no, dismiss: .no) else { return }
        current = popup
        popup.delegate = first
        popup.delegate = second
        isFirstAttached = true
        popup.isClickBgDismiss = false
        popup.popViewWillPopBlock = { [weak self] in self?.log("Block：willPop") }
        popup.popViewDidPopBlock = { [weak self] in self?.log("Block：didPop") }
        popup.popViewWillDismissBlock = { [weak self] in self?.log("Block：willDismiss") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("Block：didDismiss") }
        popup.bgClickBlock = { [weak self] in self?.log("Block：bgClick") }
        card.addButton("释放 B（卡片保持显示）", id: "advanced.lifecycle.card.releaseB") { [weak self] in self?.releaseSecond() }
        // 背景遮罩保持模态，以便演示 bgClick；需要在展示期间操作的入口必须放到卡片内。
        // 捕获特定本轮 popup 的弱引用，旧卡片即使被外部保留，也不能移除新一轮的代理。
        card.addButton("移除代理 A（保留业务持有）", id: "advanced.lifecycle.card.removeA") { [weak self, weak popup] in self?.removeFirst(from: popup) }
        card.addButton("关闭并查看事件顺序", id: "advanced.lifecycle.close") { [weak popup] in popup?.dismiss() }
        popup.pop()
    }
}

@MainActor
final class ScopeDemoViewController: DemoSceneViewController {
    private let stage = UIView(frame: CGRect(x: 0, y: 0, width: 310, height: 250))
    private var localHost: UIView?
    private var retiredPopup: NativePopup?
    private weak var observedHost: UIView?
    private var generation = 0

    init() {
        super.init(sceneTitle: "宿主与上下文失效", introduction: "下方边框是本页独立的模拟宿主。替换它相当于业务页面被销毁，不涉及登录、用户数据或系统 Scene。", learnings: [
            "创建上下文弱引用宿主；宿主释放后，旧 popup 即使仍被业务持有也失效。",
            "本页保留旧 popup 仅用于验证不能借用新宿主重新展示。新宿主必须创建新 popup。",
            "真正账号退出/切换可在替换根界面前调用 invalidateAllScopes；它会撤销全部 Swift 上下文。本页不执行该全局操作。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        stage.backgroundColor = .tertiarySystemBackground
        stage.layer.borderColor = UIColor.systemTeal.cgColor
        stage.layer.borderWidth = 2
        stage.heightAnchor.constraint(equalToConstant: 250).isActive = true
        stage.accessibilityIdentifier = "advanced.scope.stage"
        addControl(stage)
        addAction("在独立宿主中展示", accessibilityID: "advanced.scope.show") { [weak self] in self?.showInHost() }
        addAction("销毁旧宿主并建立新宿主", accessibilityID: "advanced.scope.replace") { [weak self] in self?.replaceHost() }
        addAction("尝试重新 pop 旧对象", accessibilityID: "advanced.scope.retry") { [weak self] in self?.retryOldPopup() }
        rebuildHost()
    }

    private func rebuildHost() {
        generation += 1
        let host = UIView(frame: stage.bounds)
        host.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.backgroundColor = .clear
        host.accessibilityIdentifier = "advanced.scope.host.\(generation)"
        stage.addSubview(host)
        localHost = host
        log("建立局部宿主 #\(generation)。")
    }

    private func showInHost() {
        guard let host = localHost else { return }
        for popup in NativePopup.getAllPopView(forParentView: host) { popup.dismiss(with: .no) }
        let card = AdvancedPopupCard(title: "宿主 #\(generation)", message: "按下外面的替换宿主按钮，观察此卡片和上下文失效。", width: 245, height: 200)
        guard let popup = NativePopup.initWithCustomView(card, parentView: host, popStyle: .no, dismissStyle: .no) else { return }
        retiredPopup = popup
        popup.popViewDidDismissBlock = { [weak self] in self?.log("局部 popup didDismiss：已从对应宿主移除。") }
        card.addButton("只关闭此卡片", id: "advanced.scope.card.close") { [weak popup] in popup?.dismiss() }
        popup.pop()
        log("旧对象 isPresentationContextValid=\(popup.isPresentationContextValid)。")
    }

    private func replaceHost() {
        // stage 持有 host，host 持有 popup；popup 对 host 是弱引用。
        // 先移出视图树，再释放 localHost；不保留局部强引用，便于真实观察宿主 deinit。
        observedHost = localHost
        localHost?.removeFromSuperview()
        localHost = nil
        rebuildHost()
        log("旧宿主 weak == nil：\(observedHost == nil)；保留的旧 popup 有效性：\(retiredPopup?.isPresentationContextValid ?? false)。")
        // 管理器的宿主释放哨兵在主队列清理登记项；这里让出一次执行机会，观察最终结果。
        Task { @MainActor [weak self] in
            await Task.yield()
            guard let self else { return }
            self.log("清理后：旧 popup 在视图树=\(self.retiredPopup?.superview != nil)，旧上下文有效=\(self.retiredPopup?.isPresentationContextValid ?? false)。")
        }
    }

    private func retryOldPopup() {
        guard let popup = retiredPopup else { log("请先创建旧对象，再替换宿主。 "); return }
        popup.pop()
        log("尝试 pop：有效=\(popup.isPresentationContextValid)，有 superview=\(popup.superview != nil)。失效对象不能挂到新宿主。")
    }

    override func viewWillDisappear(_ animated: Bool) {
        // base 只清 parent=self.view；本例额外拥有 child host，必须按自己的作用域收尾。
        if let host = localHost {
            for popup in NativePopup.getAllPopView(forParentView: host) { popup.dismiss(with: .no) }
        }
        retiredPopup?.dismiss(with: .no)
        localHost?.removeFromSuperview()
        localHost = nil
        retiredPopup = nil
        super.viewWillDisappear(animated)
    }
}
