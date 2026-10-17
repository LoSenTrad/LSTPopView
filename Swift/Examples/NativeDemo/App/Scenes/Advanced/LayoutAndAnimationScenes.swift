import UIKit
import LSTPopViewSwift

@MainActor
final class AnchorsDemoViewController: DemoSceneViewController {
    private let row = UISegmentedControl(items: ["上", "中", "下"])
    private let column = UISegmentedControl(items: ["左", "中", "右"])
    private let horizontal = UISlider()
    private let vertical = UISlider()

    init() {
        super.init(sceneTitle: "九宫格定位与偏移", introduction: "选择行、列得到九种 hemStyle。X/Y 偏移是在锚点结果上增加的本地坐标校准。", learnings: [
            "定位使用 parentView.bounds，不假设全屏或固定 iPhone 尺寸。",
            "示例额外给上/下边缘留出当前 safeAreaInsets，日志同时列出最终偏移。",
            "改变 adjustX/adjustY 会触发内容重排；不会修改业务内容内部约束。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        row.selectedSegmentIndex = 1
        column.selectedSegmentIndex = 1
        row.accessibilityIdentifier = "advanced.anchors.row"
        column.accessibilityIdentifier = "advanced.anchors.column"
        addControl(advancedLabel("纵向锚点")); addControl(row)
        addControl(advancedLabel("横向锚点")); addControl(column)
        for slider in [horizontal, vertical] { slider.minimumValue = -60; slider.maximumValue = 60 }
        horizontal.accessibilityIdentifier = "advanced.anchors.offsetX"
        vertical.accessibilityIdentifier = "advanced.anchors.offsetY"
        addControl(advancedLabel("X 偏移：−60…60")); addControl(horizontal)
        addControl(advancedLabel("Y 偏移：−60…60")); addControl(vertical)
        addAction("展示当前锚点", accessibilityID: "advanced.anchors.show") { [weak self] in self?.showSelection() }
    }

    private func showSelection() {
        clearScenePopups()
        let positions: [[LSTHemStyle]] = [[.topLeft, .top, .topRight], [.left, .center, .right], [.bottomLeft, .bottom, .bottomRight]]
        let names = [["左上", "上中", "右上"], ["左中", "居中", "右中"], ["左下", "下中", "右下"]]
        let r = row.selectedSegmentIndex, c = column.selectedSegmentIndex
        let card = AdvancedPopupCard(title: names[r][c], message: "点卡片内关闭，或点背景关闭。", width: 180, height: 170)
        guard let popup = makePopup(content: card, position: positions[r][c]) else { return }
        popup.adjustX = CGFloat(horizontal.value)
        let inset: CGFloat = r == 0 ? view.safeAreaInsets.top + 8 : (r == 2 ? -view.safeAreaInsets.bottom - 8 : 0)
        popup.adjustY = CGFloat(vertical.value) + inset
        popup.isClickBgDismiss = true
        popup.popViewDidPopBlock = { [weak self, weak popup] in
            guard let self, let popup else { return }
            self.log("\(names[r][c])：adjust=(\(Int(popup.adjustX)), \(Int(popup.adjustY)))；内容 frame=\(popup.currCustomView.frame)。")
        }
        card.addButton("关闭", id: "advanced.anchors.close") { [weak popup] in popup?.dismiss() }
        popup.pop()
    }
}

@MainActor
final class AnimationDemoViewController: DemoSceneViewController {
    private let entrance = UISegmentedControl(items: ["渐显", "缩放", "底入", "弹簧", "卡片"])
    private let exit = UISegmentedControl(items: ["渐隐", "缩放", "下出", "卡片"])
    private let duration = UISlider()

    init() {
        super.init(sceneTitle: "弹入与退出动画", introduction: "弹入与退出分别配置。关闭按钮会执行实际 dismiss 动画；日志记录生命周期顺序。", learnings: [
            "popStyle 与 dismissStyle 是两个独立枚举，方向以宿主坐标为准。",
            "duration 是请求时长，库会按无动画、默认样式和系统动画偏好决定有效值。",
            "系统启用减少动态效果或偏好淡入淡出时，库会将动态样式降为 fade；本页只读取设置。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        entrance.selectedSegmentIndex = 0; exit.selectedSegmentIndex = 0
        duration.minimumValue = 0.2; duration.maximumValue = 1.2; duration.value = 0.6
        entrance.accessibilityIdentifier = "advanced.animation.entrance"
        exit.accessibilityIdentifier = "advanced.animation.exit"
        duration.accessibilityIdentifier = "advanced.animation.duration"
        addControl(advancedLabel("弹入样式")); addControl(entrance)
        addControl(advancedLabel("退出样式")); addControl(exit)
        addControl(advancedLabel("请求时长：0.2～1.2 秒")); addControl(duration)
        addAction("播放所选组合", accessibilityID: "advanced.animation.show") { [weak self] in self?.play() }
        addAction("无动画生命周期", accessibilityID: "advanced.animation.none") { [weak self] in self?.play(withoutAnimation: true) }
    }

    private func play(withoutAnimation: Bool = false) {
        clearScenePopups()
        let pops: [LSTPopStyle] = [.fade, .scale, .smoothFromBottom, .springFromTop, .cardDropFromLeft]
        let dismisses: [LSTDismissStyle] = [.fade, .scale, .smoothToBottom, .cardDropToRight]
        let pop: LSTPopStyle = withoutAnimation ? .no : pops[entrance.selectedSegmentIndex]
        let dismiss: LSTDismissStyle = withoutAnimation ? .no : dismisses[exit.selectedSegmentIndex]
        let card = AdvancedPopupCard(title: "真实动画预览", message: "弹入 \(pop)\n退出 \(dismiss)\n请求 \(String(format: "%.2f", duration.value)) 秒", height: 230)
        guard let popup = makePopup(content: card, pop: pop, dismiss: dismiss) else { return }
        popup.popDuration = TimeInterval(duration.value)
        popup.dismissDuration = TimeInterval(duration.value)
        popup.popViewWillPopBlock = { [weak self] in self?.log("1. willPop") }
        popup.popViewDidPopBlock = { [weak self] in self?.log("2. didPop") }
        popup.popViewWillDismissBlock = { [weak self] in self?.log("3. willDismiss") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("4. didDismiss") }
        card.addButton("执行退出动画", id: "advanced.animation.close") { [weak popup] in popup?.dismiss() }
        log("请求 pop=\(pop)，dismiss=\(dismiss)；减少动态效果=\(UIAccessibility.isReduceMotionEnabled)。")
        popup.pop()
    }
}

@MainActor
final class DynamicContentDemoViewController: DemoSceneViewController {
    init() {
        super.init(sceneTitle: "动态内容与圆角", introduction: "在同一张底部卡片内增减高度。库观察真实 frame/bounds 变化后，重新计算贴底定位与圆角 mask。", learnings: [
            "业务负责给内容明确尺寸；库不替换业务布局或复制 View。",
            "height 从 220 变为 340 后底边保持相同，变化主要向上展开。",
            "rectCorners 控制指定角；动态尺寸下圆角路径也需要重算。"
        ])
    }
    required init?(coder: NSCoder) { fatalError("使用代码初始化") }

    override func configureDemo() {
        addAction("打开可变高度卡片", accessibilityID: "advanced.dynamic.show") { [weak self] in self?.showCard() }
    }

    private func showCard() {
        clearScenePopups()
        let card = AdvancedPopupCard(title: "高度 220 → 340", message: "点击展开/收起，观察内容顶部移动，而底部定位保持。", height: 220)
        // 本页专门观察库的指定角 mask，取消演示卡片自己的全角圆角，避免叠加后难以区分。
        card.layer.cornerRadius = 0
        guard let popup = makePopup(content: card, position: .bottom) else { return }
        popup.adjustY = -view.safeAreaInsets.bottom - 8
        popup.rectCorners = [.topLeft, .topRight]
        popup.cornerRadius = 24
        card.addButton("展开 / 收起", id: "advanced.dynamic.resize") { [weak self, weak card, weak popup] in
            guard let self, let card, let popup else { return }
            var frame = card.frame
            frame.size.height = frame.height < 300 ? 340 : 220
            card.frame = frame
            card.setNeedsLayout()
            card.layoutIfNeeded()
            self.log("内容 height=\(Int(card.bounds.height))；贴底 frame=\(popup.currCustomView.frame)，top 圆角=24。")
        }
        card.addButton("关闭", id: "advanced.dynamic.close") { [weak popup] in popup?.dismiss() }
        popup.pop()
    }
}
