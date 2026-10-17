import UIKit
import LSTPopViewSwift

/// 确认结果只是页面内的整数计数；没有删除文件、账号或提交网络请求。
@MainActor
final class BasicConfirmationScene: DemoSceneViewController {
    private let backgroundDismiss = UISwitch()
    private var acceptedCount = 0

    init() {
        super.init(sceneTitle: "确认框与短提示", introduction: "从最小确认框开始，分别观察按钮、背景点击和倒计时产生的结果。确认操作只增加本页计数。", learnings: [
            "卡片内部使用 Auto Layout，但展示前已计算出真实宽高。",
            "内容按钮由 popup 间接强持有，闭包需要 weak 捕获 popup 和页面。",
            "didDismiss 表示本轮已经移出父视图；它不依赖对象是否立即释放。"
        ])
    }

    required init?(coder: NSCoder) { fatalError("This demo creates pages in Swift") }

    override func configureDemo() {
        backgroundDismiss.isOn = false
        backgroundDismiss.accessibilityIdentifier = "basic.confirm.backgroundDismiss"
        let row = UIStackView(arrangedSubviews: [BasicUI.label("允许点击背景关闭"), backgroundDismiss])
        row.spacing = 12
        addControl(row)
        addAction("显示确认框", subtitle: "确认只更新本地计数，取消不修改结果", accessibilityID: "basic.confirm.show") { [weak self] in self?.showConfirmation() }
        addAction("显示 3 秒短提示", subtitle: "观察真实倒计时和自动关闭，也可提前关闭", accessibilityID: "basic.confirm.toast") { [weak self] in self?.showTimedNotice() }
    }

    private func showConfirmation() {
        // 用弱局部变量让两个按钮安全地访问稍后才创建的 popup。
        // 页面无需强保存它；展示期间由库的 Session 持有，关闭后解除持有。
        weak var weakPopup: NativePopup?
        let cancel = BasicUI.button("取消", id: "basic.confirm.cancel") { [weak self] in
            self?.log("取消：本地确认计数保持不变。")
            weakPopup?.dismiss()
        }
        let confirm = BasicUI.button("确认演示操作", id: "basic.confirm.accept") { [weak self] in
            guard let self else { return }
            self.acceptedCount += 1
            self.log("确认成功：本页累计 \(self.acceptedCount) 次；没有执行外部操作。")
            weakPopup?.dismiss()
        }
        let content = BasicUI.card(width: BasicUI.width(in: view), title: "执行演示操作？", message: "这是一份本地演示数据。点击确认只更新本页结果日志，你可以反复比较确认和取消。", controls: [BasicUI.row([cancel, confirm])])
        guard let popup = makePopup(content: content, pop: .scale, dismiss: .scale, group: "basic.confirm") else { return }
        weakPopup = popup
        popup.isSingle = true
        popup.isClickBgDismiss = backgroundDismiss.isOn
        popup.bgClickBlock = { [weak self] in self?.log("点击背景：是否关闭取决于上方开关。") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("didDismiss：确认框已从本页视图树移除。") }
        popup.pop()
        log("展示确认框，背景关闭：\(backgroundDismiss.isOn ? "开启" : "关闭")。")
    }

    private func showTimedNotice() {
        weak var weakPopup: NativePopup?
        let status = BasicUI.label("剩余约 3 秒", bold: true, color: .systemTeal)
        status.accessibilityIdentifier = "basic.confirm.countdown"
        let close = BasicUI.button("提前关闭", id: "basic.confirm.toast.close") { weakPopup?.dismiss() }
        let content = BasicUI.card(width: BasicUI.width(in: view), title: "操作提示", message: "showTime 从展示完成后开始计时。提前关闭会取消本轮计时器。", controls: [status, close])
        guard let popup = makePopup(content: content, group: "basic.confirm") else { return }
        weakPopup = popup
        popup.isSingle = true
        popup.showTime = 3
        popup.popViewCountDownBlock = { [weak status] _, remaining in
            // 只 weak 捕获标签；标签不应通过回调反向持有整个 popup。
            status?.text = String(format: "剩余 %.1f 秒", max(0, remaining))
        }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("短提示已关闭：可再点按钮创建一轮新的演示。") }
        popup.pop()
        log("已开始 3 秒提示，可观察自动关闭或手工关闭。")
    }
}
