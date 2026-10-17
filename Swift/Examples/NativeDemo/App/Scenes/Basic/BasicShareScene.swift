import UIKit
import LSTPopViewSwift

/// 分享入口只有本地日志，没有调用系统分享、剪贴板、相册或任何第三方 SDK。
@MainActor
final class BasicShareScene: DemoSceneViewController {
    init() {
        super.init(sceneTitle: "底部分享面板", introduction: "一个有真实按钮的底部面板。所有渠道都只模拟成功回调，不发送数据，也不读取真实个人资料。", learnings: [
            "贴底只改变定位，不会替自定义内容计算高度；每次展示按当前页面宽度重新测量。",
            "底部偏移根据当前页面的安全区计算，不写死某种 iPhone 的尺寸。",
            "按钮、背景和向下拖动都可以关闭面板；业务回调始终 weak 捕获页面。"
        ])
    }

    required init?(coder: NSCoder) { fatalError("This demo creates pages in Swift") }

    override func configureDemo() {
        addAction("打开模拟分享面板", subtitle: "点渠道查看结果，也可点击背景或向下拖动关闭", accessibilityID: "basic.share.show") { [weak self] in self?.showSharePanel() }
        addAction("清理本页弹窗", subtitle: "只操作当前演示页的 parent，不清空其他页面", accessibilityID: "basic.share.clear") { [weak self] in self?.clearScenePopups() }
    }

    private func showSharePanel() {
        weak var weakPopup: NativePopup?
        let choices = ["微信", "朋友圈", "复制链接", "保存图片"]
        let buttons = choices.enumerated().map { index, title in
            BasicUI.button("\(title)\n（模拟）", id: "basic.share.channel.\(index)") { [weak self] in
                self?.log("模拟 \(title) 回调：演示内容已选择，未发生实际分享/复制/保存。")
                weakPopup?.dismiss()
            }
        }
        let cancel = BasicUI.button("取消", id: "basic.share.cancel") { [weak self] in
            self?.log("已取消分享面板。")
            weakPopup?.dismiss()
        }
        let content = BasicUI.card(width: BasicUI.width(in: view, maximum: 520, inset: 12), title: "分享演示卡片", message: "这是本地示例。请选择一个模拟渠道，或者向下拖动面板。", controls: [BasicUI.row(Array(buttons.prefix(2))), BasicUI.row(Array(buttons.suffix(2))), cancel])
        guard let popup = makePopup(content: content, position: .bottom, pop: .smoothFromBottom, dismiss: .smoothToBottom, group: "basic.share") else { return }
        weakPopup = popup
        popup.isSingle = true
        popup.adjustY = -max(12, view.safeAreaInsets.bottom)
        popup.cornerRadius = 20
        popup.isClickBgDismiss = true
        popup.dragStyle = .y_Positive
        popup.dragDistance = 90
        popup.bgClickBlock = { [weak self] in self?.log("点击背景关闭分享面板。") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("面板 didDismiss；本轮已移除。") }
        popup.pop()
        log("面板已贴底展示：四个渠道均为模拟操作。")
    }
}
