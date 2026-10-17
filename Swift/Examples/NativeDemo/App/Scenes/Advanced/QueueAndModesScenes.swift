import UIKit
import LSTPopViewSwift

@MainActor
final class QueueDemoViewController: DemoSceneViewController {
    private var sequence = 0

    init() {
        super.init(sceneTitle: "优先级队列与分组", introduction: "按顺序点击低优先级、高优先级、同级新窗，再从卡片关闭。背景设为穿透，便于继续点击本页控制项。", learnings: [
            "同一父视图和 group 内，较高优先级会挂起旧窗；关闭后恢复等待项。",
            "同级新窗会抢占旧窗。Session 会固定入队配置，中途改 priority 不重排当前轮。",
            "不同 group 独立处理，可以同时显示；日志的‘在视图树’只说明实际挂载。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        addAction("加入低优先级 100", accessibilityID: "advanced.queue.low") { [weak self] in self?.enqueue(priority: 100, group: "A") }
        addAction("加入高优先级 900", accessibilityID: "advanced.queue.high") { [weak self] in self?.enqueue(priority: 900, group: "A") }
        addAction("加入同级新窗 900", accessibilityID: "advanced.queue.equal") { [weak self] in self?.enqueue(priority: 900, group: "A") }
        addAction("加入独立分组 B", accessibilityID: "advanced.queue.groupB") { [weak self] in self?.enqueue(priority: 50, group: "B") }
        addAction("打印本页队列快照", accessibilityID: "advanced.queue.inspect") { [weak self] in self?.inspect() }
        addAction("仅清理本页弹窗", accessibilityID: "advanced.queue.clear") { [weak self] in
            self?.clearScenePopups()
            self?.log("已清理本页；不调用全局 removeAllPopView。")
        }
    }

    private func enqueue(priority: CGFloat, group: String) {
        sequence += 1
        let name = "\(group)-\(sequence) / 优先级 \(Int(priority))"
        let card = AdvancedPopupCard(title: name, message: "关闭当前卡片，观察同组被挂起的窗口恢复。", height: 190, color: group == "A" ? .systemTeal : .systemPurple)
        guard let popup = makePopup(content: card, position: .bottom, group: "queue.\(group)", priority: priority) else { return }
        popup.identifier = name
        popup.isHideBg = true
        popup.adjustY = group == "A" ? -view.safeAreaInsets.bottom - 12 : -view.safeAreaInsets.bottom - 218
        popup.popViewDidPopBlock = { [weak self] in self?.log("didPop：\(name)") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("didDismiss：\(name)，随后观察队列恢复。") }
        card.addButton("关闭 \(name)", id: "advanced.queue.popup.close") { [weak popup] in popup?.dismiss() }
        popup.pop()
        inspect()
    }

    private func inspect() {
        let entries = NativePopup.getAllPopView(forParentView: view)
        log("本页登记 \(entries.count) 项：" + entries.map { "\($0.identifier ?? "未命名") [\($0.superview == nil ? "等待/挂起" : "在视图树")]" }.joined(separator: "；"))
    }
}

@MainActor
final class ModesDemoViewController: DemoSceneViewController {
    private var stackIndex = 0
    private var singleIndex = 0

    init() {
        super.init(sceneTitle: "堆叠与单显", introduction: "左侧概念是‘多张都留下’，右侧概念是‘只保留新的一张’。两组使用不同 group，可直接对照观察。", learnings: [
            "isStack=true：同组多项可同时可见，不靠 priority 互相挂起。",
            "isSingle=true：先完成同组旧项移除，再展示新项。",
            "模式在入队时固定；需要变更当前轮策略时，应关闭后重新 pop。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        addAction("新增堆叠卡片", accessibilityID: "advanced.modes.stack") { [weak self] in self?.show(stack: true) }
        addAction("新增单显卡片", accessibilityID: "advanced.modes.single") { [weak self] in self?.show(stack: false) }
        addAction("清理这两组", accessibilityID: "advanced.modes.clear") { [weak self] in self?.clearScenePopups(); self?.log("本页两组已关闭。") }
    }

    private func show(stack: Bool) {
        if stack { stackIndex += 1 } else { singleIndex += 1 }
        let index = stack ? stackIndex : singleIndex
        let name = "\(stack ? "Stack" : "Single") 第 \(index) 张"
        let card = AdvancedPopupCard(title: name, message: stack ? "多次点击新增，观察卡片错位堆叠；关闭上层后下层仍在。" : "再点‘新增单显’，观察旧项 didDismiss 先于新项 didPop。", height: 190, color: stack ? .systemBlue : .systemPink)
        guard let popup = makePopup(content: card, position: .bottom, group: stack ? "mode.stack" : "mode.single") else { return }
        popup.isStack = stack
        popup.isSingle = !stack
        popup.isHideBg = true
        // 有限错位使层次可见，不让不断新增的示例移出安全区。
        popup.adjustX = stack ? CGFloat(index % 3 - 1) * 12 : 0
        popup.adjustY = -view.safeAreaInsets.bottom - (stack ? 14 + CGFloat(index % 3) * 18 : 255)
        popup.identifier = name
        popup.popViewDidPopBlock = { [weak self] in self?.log("didPop：\(name)") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("didDismiss：\(name)") }
        card.addButton("关闭此卡片") { [weak popup] in popup?.dismiss() }
        popup.pop()
        log("入队 \(name)：stack=\(stack)，single=\(!stack)。")
    }
}
