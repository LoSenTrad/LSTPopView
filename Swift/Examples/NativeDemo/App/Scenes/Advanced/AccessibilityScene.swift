import UIKit
import LSTPopViewSwift

@MainActor
final class AccessibilityDemoViewController: DemoSceneViewController {
    private let counter = UILabel()
    private var taps = 0

    init() {
        super.init(sceneTitle: "透明背景与辅助功能", introduction: "分别打开普通模态卡片和透明背景卡片，再尝试点底层计数按钮。这里只读取系统辅助功能偏好，不修改 VoiceOver 或系统设置。", learnings: [
            "isHideBg=true 同时使背景 hitTest 穿透，并将 accessibilityViewIsModal 设为 false。卡片自己的按钮仍可操作。",
            "普通有背景弹窗是模态；VoiceOver 已启用时，展示/关闭由库发送焦点通知并防止旧回调抢焦点。",
            "本页只能观察当前系统设置及实际触摸；不能把未启用 VoiceOver 时的结果称为读屏验收。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        counter.text = "底层按钮点击：0 次"
        counter.accessibilityIdentifier = "advanced.accessibility.counter"
        addControl(counter)
        addAction("底层计数按钮", accessibilityID: "advanced.accessibility.underlying") { [weak self] in
            guard let self else { return }
            self.taps += 1
            self.counter.text = "底层按钮点击：\(self.taps) 次"
            self.log("底层真实按钮收到点击：\(self.taps)。")
        }
        addAction("普通模态卡片", accessibilityID: "advanced.accessibility.modal") { [weak self] in self?.show(transparent: false) }
        addAction("透明穿透卡片", accessibilityID: "advanced.accessibility.transparent") { [weak self] in self?.show(transparent: true) }
        addAction("读取当前系统辅助功能偏好", accessibilityID: "advanced.accessibility.inspect") { [weak self] in self?.inspectPreferences() }
        inspectPreferences()
    }

    private func inspectPreferences() {
        log("VoiceOver=\(UIAccessibility.isVoiceOverRunning)；减少动态效果=\(UIAccessibility.isReduceMotionEnabled)；偏好交叉淡入淡出=\(UIAccessibility.prefersCrossFadeTransitions)。未修改任何设置。")
    }

    private func show(transparent: Bool) {
        clearScenePopups()
        let card = AdvancedPopupCard(title: transparent ? "透明背景 · 非模态" : "有背景 · 模态", message: transparent ? "卡片外点底层计数按钮，应能收到点击。卡片自身仍接受触摸。" : "卡片外触摸由背景接收，底层计数按钮不应增加。请从卡片按钮关闭。", height: 230)
        card.heading.accessibilityTraits = .header
        card.isAccessibilityElement = false
        guard let popup = makePopup(content: card, position: .bottom, pop: .scale, dismiss: .scale) else { return }
        popup.adjustY = -view.safeAreaInsets.bottom - 10
        popup.isHideBg = transparent
        popup.isClickBgDismiss = false
        popup.bgClickBlock = { [weak self] in self?.log("有背景层收到点击，底层按钮未被触发。") }
        popup.popViewDidPopBlock = { [weak self, weak popup] in
            guard let self, let popup else { return }
            self.log("显示完成：isHideBg=\(popup.isHideBg)，accessibilityViewIsModal=\(popup.accessibilityViewIsModal)。")
        }
        popup.popViewDidDismissBlock = { [weak self] in
            self?.log("didDismiss：若 VoiceOver 原本开启，可人工观察焦点恢复；本页不伪造系统读屏状态。")
        }
        card.addButton("关闭卡片", id: "advanced.accessibility.close") { [weak popup] in popup?.dismiss() }
        popup.pop()
    }
}
