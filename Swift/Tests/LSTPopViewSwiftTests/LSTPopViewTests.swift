// LSTPopViewSwift 的 UIKit 行为回归测试，不依赖宿主项目的业务 View、账号或网络请求。
// 真实 UIWindow 承载独立 parentView，观察实际 superview/frame/hitTest/通知与代理输出。
// 运行要求：iOS Simulator / device 上的 UIKit test host 已建立一个 UIWindowScene；不能用 macOS swift test。
// 等待工具使用 iOS 15 已支持的单调 systemUptime / Task.sleep(nanoseconds:)，不提高库的平台下限。
// Swift Testing 不允许给 @Suite / @Test 添加 @available，因此不能靠给套件标注高版本来绕过平台检查。
// 全组串行执行。普通用例只清理自身 parent；专门的全局失效/清场用例会调用公开清理 API，
// 因此应在专用测试宿主中运行，不应在承载真实用户会话的应用里执行这组测试。
// 辅助功能测试注入环境来验证通知与焦点恢复契约，不声称替代真实 VoiceOver 人工验证。
// 计时测试替换单调时间来源；Timer、主 runloop 与生产到期处理仍使用真实路径。

import UIKit
import Testing
@testable import LSTPopViewSwift

/// 代理与 Block 共用的事件记录，能断言跨两种出口的先后顺序，而不仅检查“被调用过”。
@MainActor
private final class PopEventTrace {
    var events = [String]()
}

/// 真正安装进弱多代理池的接收者；不调用弹窗内部状态，不替生产代码推导生命周期。
@MainActor
private final class PopDelegateProbe: LSTPopViewProtocol {
    /// 每个代理独享前缀，能识别删掉其中一个后是否误删其它代理。
    let prefix: String
    /// 记录器由测试所有；代理可释放而记录仍保留，便于验证弱引用。
    let trace: PopEventTrace

    init(_ prefix: String = "delegate", trace: PopEventTrace) { self.prefix = prefix; self.trace = trace }
    func lst_PopViewBgClick(for popView: LSTPopView) { record("bg") }
    func lst_PopViewWillPop(for popView: LSTPopView) { record("willPop") }
    func lst_PopViewDidPop(for popView: LSTPopView) { record("didPop") }
    func lst_PopViewWillDismiss(for popView: LSTPopView) { record("willDismiss") }
    func lst_PopViewDidDismiss(for popView: LSTPopView) { record("didDismiss") }
    func lst_PopViewCountDownFinish(for popView: LSTPopView) { record("countDownFinish") }
    private func record(_ event: String) { trace.events.append("\(prefix).\(event)") }
}

/// 可手动推进的单调时钟；只替换时间来源，Timer/runloop 与生产到期逻辑仍真实执行。
/// 不修改设备时间，也不通过把 showTime 改成毫秒来代替长倒计时的业务断言。
@MainActor
private final class PopManualClock: LSTPopViewClock {
    var now: TimeInterval
    init(now: TimeInterval) { self.now = now }
}

/// 使用非 key 的真实窗口，避免抢走正在运行应用的键盘焦点。所有断言仍经过 UIKit 视图树。
@MainActor
private final class PopWindowFixture {
    /// 窗口强持有根控制器，parent 是其子视图；无需依赖应用当前 tab 或登录状态。
    let window: UIWindow
    /// 固定 320×640 的本地坐标，与屏幕及窗口尺寸不同，能检出错误使用 UIScreen 的定位实现。
    let parent: UIView
    /// 所有本例创建的容器，仅用于范围内清理；不持有弹窗本身，以免掩盖 manager 的释放问题。
    private var parents = [UIView]()

    init() throws {
        // UIKit 的 window↔screen 转换需要真实 scene；仅 UIWindow(frame:) 的非 key 测试窗可能无 scene，
        // 此时 screen 转换会返回 zero，制造假键盘通知。使用现有 scene，但不调用 makeKeyAndVisible。
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = try #require(scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first,
                                 "UIKit coordinate tests require a connected UIWindowScene")
        window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        let root = UIViewController()
        window.rootViewController = root
        window.isHidden = false
        root.view.frame = window.bounds
        parent = UIView(frame: CGRect(x: 20, y: 30, width: 320, height: 640))
        root.view.addSubview(parent)
        parents = [parent]
        window.layoutIfNeeded()
    }

    /// 需要校验 parent 隔离时，创建同一个 UIWindow 中的第二个独立容器。
    func additionalParent() -> UIView {
        let view = UIView(frame: CGRect(x: 5, y: 5, width: 320, height: 640))
        window.rootViewController!.view.addSubview(view)
        parents.append(view)
        return view
    }

    /// 默认裸内容尺寸固定，用旧公开工厂与 .NO 样式，避免把测试时序建立在动画时长猜测上。
    func popup(content: UIView? = nil, parent: UIView? = nil) throws -> LSTPopView {
        let content = content ?? UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 80))
        return try #require(LSTPopView.initWithCustomView(content, parentView: parent ?? self.parent,
                                                        popStyle: .NO, dismissStyle: .NO))
    }

    /// 每个测试 defer 调用；仅移除本例 parent 的弹窗，失败路径也不会留下弹窗或倒计时。
    /// .NO 使清理不依赖未完成的展示动画，重复遍历覆盖移除顶层后恢复出的等待弹窗。
    func close() {
        for parent in parents {
            for _ in 0..<3 {
                let popups = LSTPopView.getAllPopView(forParentView: parent)
                if popups.isEmpty { break }
                popups.forEach { $0.dismiss(with: .NO, duration: 0) }
            }
            parent.removeFromSuperview()
        }
        window.isHidden = true
        window.rootViewController = nil
    }
}

/// 最多两秒等待真实动画/通知/计时交付，满足条件立即继续；不阻塞主线程。
@MainActor
private func popEventually(_ predicate: () -> Bool) async throws {
    let deadline = ProcessInfo.processInfo.systemUptime + 2
    while !predicate(), ProcessInfo.processInfo.systemUptime < deadline {
        try await Task.sleep(nanoseconds: 5_000_000)
    }
    try #require(predicate(), "Expected UIKit popup behavior within two seconds")
}

/// 主队列与自动释放池获得轮次，供释放和“无额外事件”断言使用，而非固定长等待。
@MainActor
private func popDeliveryTurn() async {
    await Task.yield()
    await withCheckedContinuation { continuation in DispatchQueue.main.async { continuation.resume() } }
}

/// 锚点使用固定输入的独立期望坐标，避免在测试里复制生产布局公式再互相证明。
private let popAnchorCases: [(LSTHemStyle, CGPoint)] = [
    (.center, CGPoint(x: 107, y: 269)), (.top, CGPoint(x: 107, y: -11)),
    (.left, CGPoint(x: 7, y: 269)), (.bottom, CGPoint(x: 107, y: 549)),
    (.right, CGPoint(x: 207, y: 269)), (.topLeft, CGPoint(x: 7, y: -11)),
    (.bottomLeft, CGPoint(x: 7, y: 549)), (.bottomRight, CGPoint(x: 207, y: 549)),
    (.topRight, CGPoint(x: 207, y: -11))
]

@Suite("LSTPopViewSwift · UIKit 行为契约", .serialized)
@MainActor
struct LSTPopViewTests {
    @Test("强持有弹窗仍按真实移除触发生命周期，重复pop/dismiss不重复发事件")
    func lifecycleAndRepeatedOperations() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        let trace = PopEventTrace()
        let delegate = PopDelegateProbe(trace: trace)
        defer { withExtendedLifetime(delegate) {} }
        popup.delegate = delegate
        popup.popViewWillPopBlock = { trace.events.append("block.willPop") }
        popup.popViewDidPopBlock = { trace.events.append("block.didPop") }
        popup.popViewWillDismissBlock = { trace.events.append("block.willDismiss") }
        popup.popViewDidDismissBlock = { trace.events.append("block.didDismiss") }
        popup.pop()
        popup.pop()
        try await popEventually { trace.events.contains("block.didPop") }
        #expect(popup.superview === fixture.parent)
        #expect(trace.events == ["delegate.willPop", "block.willPop", "delegate.didPop", "block.didPop"])
        #expect(LSTPopView.getAllPopView(forParentView: fixture.parent).filter { $0 === popup }.count == 1)

        popup.dismiss()
        popup.dismiss()
        try await popEventually { popup.superview == nil && trace.events.contains("block.didDismiss") }
        #expect(trace.events.suffix(4) == ["delegate.willDismiss", "block.willDismiss", "delegate.didDismiss", "block.didDismiss"])
        #expect(trace.events.filter { $0 == "block.didDismiss" }.count == 1)
        #expect(!LSTPopView.getAllPopView(forParentView: fixture.parent).contains { $0 === popup })
        // popup 仍为强局部变量，以上 didDismiss 不能靠 deinit 才发生。
        #expect(popup.currCustomView.frame.size == CGSize(width: 120, height: 80))
    }

    @Test("九种锚点与偏移均以parent本地尺寸定位", arguments: Array(popAnchorCases.indices))
    func anchorsUseParentCoordinates(index: Int) async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        let (anchor, expected) = popAnchorCases[index]
        popup.hemStyle = anchor
        popup.adjustX = 7
        popup.adjustY = -11
        popup.pop()
        try await popEventually { popup.superview != nil }
        #expect(popup.frame == fixture.parent.bounds)
        #expect(popup.currCustomView.frame == CGRect(origin: expected, size: CGSize(width: 120, height: 80)))
    }

    @Test("遮罩点击按代理、Block、移除生命周期顺序交付")
    func backgroundClickOrder() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        let trace = PopEventTrace()
        let delegate = PopDelegateProbe(trace: trace)
        defer { withExtendedLifetime(delegate) {} }
        popup.delegate = delegate
        popup.isClickBgDismiss = true
        popup.bgClickBlock = { trace.events.append("block.bg") }
        popup.popViewWillDismissBlock = { trace.events.append("block.willDismiss") }
        popup.popViewDidDismissBlock = { trace.events.append("block.didDismiss") }
        popup.pop()
        try await popEventually { trace.events.contains("delegate.didPop") }
        trace.events.removeAll()
        // 触发原库保留的同一手势 action，不直接调用 bgClickBlock 或 dismiss 伪造按钮行为。
        popup.popViewBgViewTap(UITapGestureRecognizer())
        try await popEventually { popup.superview == nil }
        #expect(trace.events == ["delegate.bg", "block.bg", "delegate.willDismiss", "block.willDismiss",
                                 "delegate.didDismiss", "block.didDismiss"])
    }

    @Test("代理池追加弱代理，删除一个不误伤另一个，removeAll停止后续通知")
    func weakMultipleDelegatesAndRemoval() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        let trace = PopEventTrace()
        var ephemeral: PopDelegateProbe? = PopDelegateProbe("ephemeral", trace: trace)
        weak var weakDelegate = ephemeral
        popup.delegate = ephemeral
        ephemeral = nil
        #expect(weakDelegate == nil)
        let first = PopDelegateProbe("first", trace: trace)
        let second = PopDelegateProbe("second", trace: trace)
        // 代理池本身必须弱持有；测试主动维持这些预期仍在监听的外部代理生命，避免 ARC 提前释放。
        defer { withExtendedLifetime(first) {}; withExtendedLifetime(second) {} }
        popup.delegate = first
        popup.delegate = second
        popup.remove(forDelegate: first)
        popup.pop()
        try await popEventually { trace.events.contains("second.didPop") }
        #expect(!trace.events.contains { $0.hasPrefix("first.") || $0.hasPrefix("ephemeral.") })
        popup.removeAllDelegate()
        popup.dismiss()
        try await popEventually { popup.superview == nil }
        #expect(trace.events == ["second.willPop", "second.didPop"])
    }

    @Test("低优先级等待，高优先级和同优先级抢占，关闭后恢复正确窗口")
    func priorityQueueAndEqualPriorityPreemption() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let high = try fixture.popup()
        let low = try fixture.popup()
        let equal = try fixture.popup()
        [high, low, equal].forEach { $0.groupId = "queue" }
        high.priority = 100
        low.priority = 10
        equal.priority = 100
        high.pop()
        low.pop()
        try await popEventually { high.superview != nil }
        #expect(low.superview == nil)
        #expect(LSTPopView.getAllPopView(for: high).count == 2)
        equal.pop()
        try await popEventually { equal.superview != nil && high.superview == nil }
        equal.dismiss()
        try await popEventually { equal.superview == nil && high.superview != nil }
        high.dismiss()
        try await popEventually { high.superview == nil && low.superview != nil }
        #expect(LSTPopView.getAllPopView(for: low).count == 1)
    }

    @Test("parent与group隔离，按唯一标识查找和移除不会误伤其它组")
    func parentGroupIsolationAndManagerLookup() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let otherParent = fixture.additionalParent()
        let a = try fixture.popup()
        let b = try fixture.popup()
        let c = try fixture.popup(parent: otherParent)
        a.groupId = "A"
        b.groupId = "B"
        c.groupId = "A"
        a.identifier = UUID().uuidString
        b.identifier = UUID().uuidString
        c.identifier = UUID().uuidString
        a.pop(); b.pop(); c.pop()
        try await popEventually { a.superview != nil && b.superview != nil && c.superview != nil }
        #expect(LSTPopView.getAllPopView(forParentView: fixture.parent).count == 2)
        #expect(LSTPopView.getAllPopView(for: a).count == 1)
        #expect(LSTPopView.getPopView(forKey: b.identifier!) === b)
        LSTPopView.removePopView(forKey: b.identifier!)
        try await popEventually { b.superview == nil }
        #expect(a.superview === fixture.parent)
        #expect(c.superview === otherParent)
        #expect(LSTPopView.getPopView(forKey: b.identifier!) == nil)
    }

    @Test("stack并排保留视图，single只清理同parent和group且不复活旧窗")
    func stackingAndSingleMode() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let first = try fixture.popup()
        let stacked = try fixture.popup()
        let single = try fixture.popup()
        let independent = try fixture.popup()
        [first, stacked, single].forEach { $0.groupId = "replace" }
        independent.groupId = "independent"
        stacked.isStack = true
        first.pop(); stacked.pop(); independent.pop()
        try await popEventually { first.superview != nil && stacked.superview != nil && independent.superview != nil }
        single.isSingle = true
        single.pop()
        try await popEventually { single.superview != nil && first.superview == nil && stacked.superview == nil }
        #expect(LSTPopView.getAllPopView(for: single).count == 1)
        #expect(independent.superview === fixture.parent)
        single.dismiss()
        try await popEventually { single.superview == nil }
        #expect(first.superview == nil && stacked.superview == nil)
        #expect(independent.superview === fixture.parent)
    }

    @Test("隐藏背景时触摸穿透到下层按钮，弹窗内容仍正常命中")
    func transparentBackgroundHitTesting() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let underlying = UIButton(frame: fixture.parent.bounds)
        fixture.parent.addSubview(underlying)
        let content = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 80))
        let popup = try fixture.popup(content: content)
        popup.isHideBg = true
        popup.pop()
        try await popEventually { popup.superview != nil }
        #expect(fixture.parent.hitTest(CGPoint(x: 2, y: 2), with: nil) === underlying)
        let contentPoint = CGPoint(x: content.frame.midX, y: content.frame.midY)
        #expect(fixture.parent.hitTest(contentPoint, with: nil) === content)
        popup.isHideBg = false
        let blocked = fixture.parent.hitTest(CGPoint(x: 2, y: 2), with: nil)
        #expect(blocked !== underlying)
        #expect(blocked?.isDescendant(of: popup) == true)
    }

    @Test("single替换旧窗时旧回调再弹第三窗，事务结束后仍只有正确顶层可见")
    func singleReplacementSerializesReentrantPresentation() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let old = try fixture.popup()
        let replacement = try fixture.popup()
        let third = try fixture.popup()
        [old, replacement, third].forEach { $0.groupId = "reentrant-single" }
        replacement.isSingle = true
        var oldDismissals = 0
        old.popViewDidDismissBlock = { [weak third] in
            oldDismissals += 1
            third?.pop()
        }
        old.pop()
        replacement.pop()
        // 第三窗是回调里发生的后续展示意图，同级按原契约成为新顶层；replacement只能等待。
        try await popEventually { third.superview != nil && replacement.superview == nil }
        #expect(oldDismissals == 1)
        #expect(old.superview == nil)
        let remaining = LSTPopView.getAllPopView(for: third)
        #expect(remaining.count == 2)
        #expect(remaining.contains { $0 === replacement })
        #expect(remaining.contains { $0 === third })
        third.dismiss()
        try await popEventually { third.superview == nil && replacement.superview != nil }
    }

    @Test("外部remove回调再次remove且重新pop同对象，旧会话不能移除新会话")
    func externalRemovalDoesNotDestroyReopenedSession() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        var shows = 0
        var wills = 0
        var dismissals = 0
        popup.popViewDidPopBlock = { shows += 1 }
        popup.popViewWillDismissBlock = { [weak popup] in
            wills += 1
            if wills == 1 { popup?.removeFromSuperview() }
        }
        popup.popViewDidDismissBlock = { [weak popup] in
            dismissals += 1
            if dismissals == 1 { popup?.pop() }
        }
        // 清理时取消测试自己的重入回调，避免让 defer 创建新的显示意图。
        defer { popup.popViewWillDismissBlock = nil; popup.popViewDidDismissBlock = nil }
        popup.pop()
        popup.removeFromSuperview()
        try await popEventually { shows == 2 && popup.superview === fixture.parent }
        await popDeliveryTurn()
        #expect(wills == 1)
        #expect(dismissals == 1)
        #expect(popup.superview === fixture.parent)
        #expect(LSTPopView.getAllPopView(forParentView: fixture.parent).filter { $0 === popup }.count == 1)
    }

    @Test("键盘避让按容器换算位置，重复通知不累计偏移，收起恢复原位置", arguments: [true, false])
    func keyboardAvoidanceRestoresOriginalFrame(avoid: Bool) async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        // 刻意移动窗口，让屏幕坐标与 window 坐标不同，避免零原点窗口掩盖错误的 nil 转换。
        fixture.window.frame.origin = CGPoint(x: 13, y: 17)
        let content = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 180))
        let popup = try fixture.popup(content: content)
        popup.hemStyle = .bottom
        popup.isAvoidKeyboard = avoid
        popup.avoidKeyboardSpace = 10
        popup.pop()
        try await popEventually { popup.superview != nil }
        let original = content.frame
        let keyboardInWindow = CGRect(x: 0, y: 400, width: 390, height: 444)
        // 系统通知真实约定是屏幕坐标；期望值则由已知 window 内键盘位置独立计算。
        let screenFrame = fixture.window.convert(keyboardInWindow, to: fixture.window.screen.coordinateSpace)
        try #require(!screenFrame.isEmpty && !screenFrame.isNull && !screenFrame.isInfinite,
                     "Synthetic keyboard notification must carry a valid screen-coordinate frame")
        let keyboardTopInParent = fixture.parent.convert(keyboardInWindow, from: fixture.window).minY
        let info: [AnyHashable: Any] = [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: screenFrame),
                                      UIResponder.keyboardAnimationDurationUserInfoKey: 0.0]
        NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil, userInfo: info)
        await popDeliveryTurn()
        let first = content.frame
        if avoid {
            #expect(first.minY < original.minY)
            #expect(abs(first.maxY + 10 - keyboardTopInParent) < 0.01)
        } else { #expect(first == original) }
        NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil, userInfo: info)
        await popDeliveryTurn()
        #expect(content.frame == first)
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: info)
        await popDeliveryTurn()
        #expect(content.frame == original)
    }

    @Test("显示后的内容尺寸改变自动重新贴底并更新圆角遮罩")
    func contentResizingUpdatesPositionAndCorners() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let content = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 80))
        let popup = try fixture.popup(content: content)
        popup.hemStyle = .bottom
        popup.cornerRadius = 14
        popup.rectCorners = [.topLeft, .topRight]
        popup.pop()
        try await popEventually { popup.superview != nil }
        content.frame.size = CGSize(width: 140, height: 150)
        // 不替生产代码调用 layoutSubviews/setNeedsLayout；这是原 KVO 能力的真实回归验证。
        try await popEventually { content.frame.origin == CGPoint(x: 90, y: 490) }
        #expect(content.frame.size == CGSize(width: 140, height: 150))
        let mask = try #require(content.layer.mask as? CAShapeLayer)
        #expect(mask.path?.boundingBoxOfPath.size == content.bounds.size)
    }

    @Test("展示管理持有弹窗，移除后释放，不依赖业务一直持有强引用")
    func managerOwnershipEndsAtDismissal() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        var popup: LSTPopView? = try fixture.popup()
        weak var weakPopup = popup
        popup?.pop()
        popup = nil
        try await popEventually { weakPopup?.superview != nil }
        #expect(weakPopup != nil)
        weakPopup?.dismiss()
        try await popEventually { weakPopup == nil }
        #expect(LSTPopView.getAllPopView(forParentView: fixture.parent).isEmpty)
    }

    @Test("倒计时自动关闭一次；手工关闭后不再触发过期事件")
    func countdownAndEarlyDismissal() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let automatic = try fixture.popup()
        let trace = PopEventTrace()
        let delegate = PopDelegateProbe(trace: trace)
        defer { withExtendedLifetime(delegate) {} }
        automatic.delegate = delegate
        automatic.showTime = 0.05
        automatic.pop()
        try await popEventually { trace.events.contains("delegate.countDownFinish") && automatic.superview == nil }
        #expect(trace.events.filter { $0 == "delegate.didDismiss" }.count == 1)

        let manual = try fixture.popup()
        let manualTrace = PopEventTrace()
        let manualDelegate = PopDelegateProbe(trace: manualTrace)
        defer { withExtendedLifetime(manualDelegate) {} }
        manual.delegate = manualDelegate
        manual.showTime = 0.05
        manual.pop()
        manual.dismiss()
        try await popEventually { manual.superview == nil }
        // 超过已设置的真实短倒计时，验证 timer 已取消；此处等待由要验证的业务时长决定。
        try await Task.sleep(nanoseconds: 80_000_000)
        #expect(!manualTrace.events.contains("delegate.countDownFinish"))
        #expect(manualTrace.events.filter { $0 == "delegate.didDismiss" }.count == 1)
    }

    @Test("每种显示动画最终保持内容可交互且回归锚点", arguments: Array(0...12))
    func allPresentationStylesReachVisibleState(rawValue: Int) async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        popup.popStyle = try #require(LSTPopStyle(rawValue: rawValue))
        popup.popDuration = 0.01
        var didShow = 0
        popup.popViewDidPopBlock = { didShow += 1 }
        popup.pop()
        try await popEventually { didShow == 1 }
        #expect(popup.superview === fixture.parent)
        #expect(popup.currCustomView.frame == CGRect(x: 100, y: 280, width: 120, height: 80))
        #expect(popup.currCustomView.alpha == 1)
        #expect(popup.currCustomView.transform == .identity)
    }

    @Test("旧倒计时回调移除后重新弹同对象，不得终止新一轮计时或窗口")
    func countdownCallbackCannotDismissReopenedSession() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        popup.showTime = 0.03
        var reopened = false
        var shows = 0
        var dismissals = 0
        popup.popViewDidPopBlock = { shows += 1 }
        popup.popViewDidDismissBlock = { dismissals += 1 }
        popup.popViewCountDownBlock = { [weak popup] _, remaining in
            // 只在旧会话明确到期时重入，保证旧 tick 若继续执行就会误触发 finish/dismiss。
            guard remaining <= 0, !reopened, let popup = popup else { return }
            reopened = true
            popup.dismiss()
            popup.showTime = 0.5
            popup.pop()
        }
        defer { popup.popViewCountDownBlock = nil }
        popup.pop()
        try await popEventually { reopened && shows == 2 }
        // 让旧 tick 返回并再经过真实 runloop；仍早于新会话 0.5 秒的合理到期时间。
        try await Task.sleep(nanoseconds: 80_000_000)
        #expect(popup.superview === fixture.parent)
        #expect(dismissals == 1)
        #expect(LSTPopView.getAllPopView(forParentView: fixture.parent).filter { $0 === popup }.count == 1)
    }

    @Test("每种隐藏动画最终移出窗口并且仅发送一次完成事件", arguments: Array(0...9))
    func allDismissalStylesRemoveVisibleView(rawValue: Int) async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        popup.dismissStyle = try #require(LSTDismissStyle(rawValue: rawValue))
        popup.dismissDuration = 0.01
        var dismissals = 0
        popup.popViewDidDismissBlock = { dismissals += 1 }
        popup.pop()
        try await popEventually { popup.superview != nil }
        popup.dismiss()
        try await popEventually { popup.superview == nil && dismissals == 1 }
        #expect(!LSTPopView.getAllPopView(forParentView: fixture.parent).contains { $0 === popup })
    }

    // MARK: - 所有权、排队快照与会话边界回归

    @Test("single或stack显示后出现低优先级等待者，移除当前窗仍能恢复等待者", arguments: ["single", "stack"])
    func modesDoNotStrandLaterWaiters(mode: String) async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let leader = try fixture.popup()
        let waiting = try fixture.popup()
        leader.groupId = "mode-waiting"
        waiting.groupId = "mode-waiting"
        leader.priority = 100
        leader.isSingle = mode == "single"
        leader.isStack = mode == "stack"
        waiting.priority = 10
        leader.pop()
        waiting.pop()
        try await popEventually { leader.superview === fixture.parent }
        #expect(waiting.superview == nil)
        #expect(LSTPopView.getAllPopView(for: leader).count == 2)
        leader.dismiss()
        try await popEventually { waiting.superview === fixture.parent }
        #expect(leader.superview == nil)
        #expect(LSTPopView.getAllPopView(for: waiting).count == 1)
    }

    @Test("背景旧tap回调关闭后重新pop同对象，后续自动关闭不能作用于新会话")
    func backgroundTapDoesNotDismissReopenedSession() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        popup.isClickBgDismiss = true
        var shows = 0
        var dismissals = 0
        var clicks = 0
        popup.popViewDidPopBlock = { shows += 1 }
        popup.popViewDidDismissBlock = { dismissals += 1 }
        popup.bgClickBlock = { [weak popup] in
            clicks += 1
            popup?.dismiss(with: .NO, duration: 0)
            popup?.pop(with: .NO, duration: 0)
        }
        popup.pop()
        popup.popViewBgViewTap(UITapGestureRecognizer())
        try await popEventually { shows == 2 }
        await popDeliveryTurn()
        #expect(clicks == 1)
        #expect(dismissals == 1)
        #expect(popup.superview === fixture.parent)
    }

    @Test("旧didDismiss完整交付后才恢复等待窗，恢复回调重新pop不混入旧完成")
    func dismissalNotificationPrecedesQueueResumption() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let high = try fixture.popup()
        let waiting = try fixture.popup()
        high.priority = 100
        waiting.priority = 10
        high.groupId = "completion-order"
        waiting.groupId = "completion-order"
        let trace = PopEventTrace()
        high.popViewDidPopBlock = { trace.events.append("high.didPop") }
        high.popViewDidDismissBlock = { trace.events.append("high.didDismiss") }
        waiting.popViewDidPopBlock = { [weak high] in
            trace.events.append("waiting.didPop")
            high?.pop(with: .NO, duration: 0)
        }
        high.pop()
        waiting.pop()
        #expect(waiting.superview == nil)
        high.dismiss()
        try await popEventually { trace.events.filter { $0 == "high.didPop" }.count == 2 }
        #expect(trace.events == ["high.didPop", "high.didDismiss", "waiting.didPop", "high.didPop"])
        #expect(high.superview === fixture.parent)
        #expect(waiting.superview == nil)
    }

    @Test("宿主释放后自动撤销可见与等待弹窗，不由manager永久保留孤儿")
    func releasedHostPurgesVisibleAndQueuedPopups() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        var host: UIView? = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        fixture.window.rootViewController!.view.addSubview(host!)
        weak var weakHost = host
        var high: LSTPopView? = try fixture.popup(parent: host!)
        var waiting: LSTPopView? = try fixture.popup(parent: host!)
        weak var weakHigh = high
        weak var weakWaiting = waiting
        let highID = UUID().uuidString
        let waitingID = UUID().uuidString
        high?.identifier = highID
        waiting?.identifier = waitingID
        high?.priority = 100
        waiting?.priority = 10
        high?.pop()
        waiting?.pop()
        #expect(waiting?.superview == nil)
        host?.removeFromSuperview()
        host = nil
        high = nil
        waiting = nil
        // sentinel 的 deinit 通过主队列撤销 scope，允许异步清理，但必须最终释放所有登记窗口。
        try await popEventually {
            weakHost == nil && weakHigh == nil && weakWaiting == nil
                && LSTPopView.getPopView(forKey: highID) == nil
                && LSTPopView.getPopView(forKey: waitingID) == nil
        }
    }

    @Test("group优先级模式按本轮入队快照，动态属性不破坏恢复，新一轮采用新配置")
    func queueConfigurationUsesPresentationSnapshot() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let leader = try fixture.popup()
        let lower = try fixture.popup()
        let next = try fixture.popup()
        [leader, lower, next].forEach { $0.groupId = "original-group" }
        leader.priority = 100
        lower.priority = 10
        next.priority = 20
        leader.pop()
        lower.pop()
        next.pop()
        #expect(lower.superview == nil && next.superview == nil)

        // 这些是给下一轮使用的公开配置，不能改变已经登记的组、排队顺序与恢复策略。
        leader.groupId = "next-group"
        leader.isStack = true
        leader.isSingle = true
        lower.priority = 1000
        leader.dismiss()
        try await popEventually { next.superview === fixture.parent }
        #expect(lower.superview == nil)
        next.dismiss()
        try await popEventually { lower.superview === fixture.parent }

        leader.pop()
        try await popEventually { leader.superview === fixture.parent }
        #expect(lower.superview === fixture.parent)
        #expect(LSTPopView.getAllPopView(for: leader).count == 1)
        #expect(LSTPopView.getAllPopView(for: lower).count == 1)
    }

    @Test("removeAll阻断清理回调新pop，清理结束后同对象仍可正常展示")
    func removeAllBlocksReentrantPresentationOnlyDuringCleanup() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let first = try fixture.popup()
        let fromCallback = try fixture.popup()
        var completions = 0
        first.popViewDidDismissBlock = { [weak fromCallback] in
            completions += 1
            fromCallback?.pop()
        }
        first.pop()
        LSTPopView.removeAllPopView()
        await popDeliveryTurn()
        #expect(completions == 1)
        #expect(first.superview == nil && fromCallback.superview == nil)
        #expect(LSTPopView.getAllPopView(forParentView: fixture.parent).isEmpty)

        // 普通 removeAll 只清场，不永久注销创建scope；结束后用户新发起的展示意图仍可执行。
        fromCallback.pop()
        try await popEventually { fromCallback.superview === fixture.parent }
    }

    @Test("全局scope失效使旧窗及清场回调中新建窗永久失效，之后新建仍正常")
    func invalidationRejectsOldAndCallbackCreatedContexts() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let old = try fixture.popup()
        var callbackCreated: LSTPopView?
        var callbacks = 0
        old.popViewDidDismissBlock = {
            callbacks += 1
            callbackCreated = try? fixture.popup()
            callbackCreated?.pop()
        }
        defer { old.popViewDidDismissBlock = nil }
        old.pop()
        LSTPopView.invalidateAllScopes()
        try await popEventually { old.superview == nil }
        let createdDuringCleanup = try #require(callbackCreated)
        old.pop()
        createdDuringCleanup.pop()
        await popDeliveryTurn()
        #expect(callbacks == 1)
        #expect(old.superview == nil && createdDuringCleanup.superview == nil)
        #expect(LSTPopView.getAllPopView(forParentView: fixture.parent).isEmpty)

        let fresh = try fixture.popup()
        fresh.pop()
        try await popEventually { fresh.superview === fixture.parent }
    }

    @Test("可控window切换root前撤销scope，旧window层弹窗不能跨会话重现")
    func controlledRootReplacementClearsWindowPopups() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup(parent: fixture.window)
        defer { popup.dismiss(with: .NO, duration: 0) }
        popup.pop()
        try await popEventually { popup.superview === fixture.window }
        // 使用公开清场 API 与可控 window 验证根界面切换边界，不引入任何宿主业务或网络逻辑。
        LSTPopView.invalidateAllScopes()
        fixture.window.rootViewController = UIViewController()
        popup.pop()
        await popDeliveryTurn()
        #expect(popup.superview == nil)
        #expect(LSTPopView.getAllPopView(forParentView: fixture.window).isEmpty)
        let newPopup = try fixture.popup(parent: fixture.window)
        defer { newPopup.dismiss(with: .NO, duration: 0) }
        newPopup.pop()
        try await popEventually { newPopup.superview === fixture.window }
    }

    @Test("factory时未挂载的宿主之后进入真实scene，scene清场只撤销该场景的旧上下文")
    func sceneInvalidationBindsParentsAttachedAfterFactoryCreation() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let scene = try #require(fixture.window.windowScene)
        let laterAttachedParent = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        let sceneLessParent = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        #expect(laterAttachedParent.window == nil && sceneLessParent.window == nil)
        // 两者都在没有window/scene时创建；后续只有第一个宿主真正进入当前场景。
        let old = try fixture.popup(parent: laterAttachedParent)
        let independent = try fixture.popup(parent: sceneLessParent)
        defer {
            old.dismiss(with: .NO, duration: 0)
            independent.dismiss(with: .NO, duration: 0)
            laterAttachedParent.removeFromSuperview()
        }
        fixture.window.rootViewController!.view.addSubview(laterAttachedParent)
        #expect(laterAttachedParent.window === fixture.window)
        old.pop()
        independent.pop()
        try await popEventually { old.superview === laterAttachedParent && independent.superview === sceneLessParent }

        LSTPopView.invalidatePopViews(in: scene)
        // Scene清场须同步移除已归属该scene的窗，同时不能退化为全局清场误伤独立裸宿主。
        #expect(old.superview == nil)
        #expect(independent.superview === sceneLessParent)
        old.pop()
        await popDeliveryTurn()
        #expect(old.superview == nil)
        #expect(LSTPopView.getAllPopView(forParentView: laterAttachedParent).isEmpty)

        let fresh = try fixture.popup(parent: laterAttachedParent)
        defer { fresh.dismiss(with: .NO, duration: 0) }
        fresh.pop()
        try await popEventually { fresh.superview === laterAttachedParent }
        // 未归属失效scene的旧对象不仅仍在视图树，也能关闭后重开，证明其scope仍有效。
        independent.dismiss()
        independent.pop()
        try await popEventually { independent.superview === sceneLessParent }
        #expect(sceneLessParent.window == nil)
    }

    // MARK: - 可观察状态与外部环境边界

    @Test("固定几何场景只在实际遮挡时避让，巨大键盘保留顶部可见")
    func keyboardGeometryUsesRealIntersectionAndTopClamp() {
        let bounds = CGRect(x: 0, y: 0, width: 320, height: 640)
        let original = CGRect(x: 100, y: 460, width: 120, height: 180)
        // 浮动键盘在内容上方，尽管它位于同一容器内，也没有遮住内容，不能把弹窗无故推走。
        #expect(LSTPopViewLayout.avoidingKeyboard(CGRect(x: 100, y: 200, width: 120, height: 80),
                                                 original: original, in: bounds, spacing: 10) == original)
        #expect(LSTPopViewLayout.avoidingKeyboard(CGRect(x: 250, y: 450, width: 60, height: 190),
                                                 original: original, in: bounds, spacing: 10) == original)
        #expect(LSTPopViewLayout.avoidingKeyboard(CGRect(x: 0, y: 370, width: 320, height: 270),
                                                 original: original, in: bounds, spacing: 10)
                == CGRect(x: 100, y: 180, width: 120, height: 180))
        #expect(LSTPopViewLayout.avoidingKeyboard(CGRect(x: 0, y: 20, width: 320, height: 620),
                                                 original: original, in: bounds, spacing: 10)
                == CGRect(x: 100, y: 0, width: 120, height: 180))
        // 非零 bounds 原点也属于父坐标，固定期望能检出退回全局屏幕尺寸或忽略 bounds.origin。
        #expect(LSTPopViewLayout.frame(in: CGRect(x: 20, y: 40, width: 320, height: 640),
                                      contentSize: CGSize(width: 120, height: 80), hem: .bottomRight,
                                      offset: CGPoint(x: 7, y: -11))
                == CGRect(x: 227, y: 589, width: 120, height: 80))
    }

    @Test("键盘旧willShow回调重新pop后，旧通知不能移动新会话")
    func staleKeyboardNotificationCannotMoveReopenedPopup() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let content = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 180))
        let popup = try fixture.popup(content: content)
        popup.hemStyle = .bottom
        let original = CGRect(x: 100, y: 460, width: 120, height: 180)
        var shows = 0
        var didReopen = false
        popup.popViewDidPopBlock = { shows += 1 }
        popup.keyboardWillShowBlock = { [weak popup] in
            guard !didReopen else { return }
            didReopen = true
            popup?.dismiss(with: .NO, duration: 0)
            popup?.pop(with: .NO, duration: 0)
        }
        defer { popup.keyboardWillShowBlock = nil }
        popup.pop()
        let screenFrame = fixture.window.convert(CGRect(x: 0, y: 400, width: 390, height: 444),
                                                  to: fixture.window.screen.coordinateSpace)
        try #require(!screenFrame.isEmpty)
        let info: [AnyHashable: Any] = [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: screenFrame),
                                      UIResponder.keyboardAnimationDurationUserInfoKey: 0.0]
        NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil, userInfo: info)
        try await popEventually { didReopen && shows == 2 }
        await popDeliveryTurn()
        #expect(popup.superview === fixture.parent)
        #expect(content.frame == original)
    }

    @Test("单调时钟推进决定到期，实际Timer不依赖设备日历时间")
    func injectedClockControlsDeadline() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let popup = try fixture.popup()
        let clock = PopManualClock(now: 100)
        popup.countdownClock = clock
        popup.showTime = 5
        var remainingValues = [TimeInterval]()
        var dismissals = 0
        popup.popViewCountDownBlock = { _, remaining in remainingValues.append(remaining) }
        popup.popViewDidDismissBlock = { dismissals += 1 }
        popup.pop()
        clock.now = 104.9
        try await popEventually { !remainingValues.isEmpty }
        #expect(abs(remainingValues.last! - 0.1) < 0.0001)
        #expect(popup.superview === fixture.parent)
        clock.now = 105
        try await popEventually { dismissals == 1 && popup.superview == nil }
        #expect(remainingValues.last == 0)
    }

    @Test("挂起期间暂停剩余时长，恢复按同一单调时钟重新计时")
    func suspendedCountdownPreservesRemainingTime() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let lower = try fixture.popup()
        let cover = try fixture.popup()
        let clock = PopManualClock(now: 100)
        lower.countdownClock = clock
        lower.priority = 10
        cover.priority = 100
        lower.showTime = 5
        var remainingValues = [TimeInterval]()
        lower.popViewCountDownBlock = { _, remaining in remainingValues.append(remaining) }
        lower.pop()
        clock.now = 102
        cover.pop()
        #expect(lower.superview == nil)
        clock.now = 1000
        cover.dismiss()
        try await popEventually { !remainingValues.isEmpty }
        #expect(abs(remainingValues.last! - 3) < 0.0001)
        #expect(lower.superview === fixture.parent)
        clock.now = 1002.9
        try await popEventually { (remainingValues.last ?? 3) < 0.2 }
        #expect(lower.superview === fixture.parent)
        clock.now = 1003
        try await popEventually { lower.superview == nil }
    }

    @Test("遮罩弹窗为可访问性模态且生命周期通知焦点，穿透弹窗不抢焦点", arguments: [true, false])
    func accessibilityModalAndFocusContract(opaque: Bool) async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let previousButton = UIButton(frame: CGRect(x: 1, y: 1, width: 80, height: 30))
        fixture.parent.addSubview(previousButton)
        let popup = try fixture.popup()
        popup.isHideBg = !opaque
        var focusEvents = [AnyObject?]()
        popup.accessibilityEnvironment = LSTPopViewAccessibilityEnvironment(
            reduceMotion: { false }, preferCrossFade: { false }, voiceOverRunning: { true },
            focusedElement: { [weak previousButton] in previousButton },
            screenChanged: { focusEvents.append($0) })
        popup.pop()
        #expect(popup.accessibilityViewIsModal == opaque)
        if opaque {
            try await popEventually { focusEvents.count == 1 }
            // nil请UIKit在模态内选择可操作元素；这里验证通知契约，不声称已用真实VoiceOver验证首个焦点。
            #expect(focusEvents[0] == nil)
        } else {
            await popDeliveryTurn()
            #expect(focusEvents.isEmpty)
        }
        popup.dismiss()
        if opaque {
            // 恢复在移除后的主队列轮次发生，不能在新界面层次尚未稳定时抢回焦点。
            #expect(focusEvents.count == 1)
            try await popEventually { focusEvents.count == 2 }
            #expect(focusEvents[1] === previousButton)
        } else {
            await popDeliveryTurn()
            #expect(focusEvents.isEmpty)
        }
    }

    @Test("重新pop或账号scope失效时旧焦点恢复任务不能抢回焦点", arguments: ["reopen", "invalidate"])
    func obsoleteAccessibilityRestorationIsRejected(reason: String) async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        let previousButton = UIButton(frame: CGRect(x: 1, y: 1, width: 80, height: 30))
        fixture.parent.addSubview(previousButton)
        let popup = try fixture.popup()
        var focusEvents = [AnyObject?]()
        var didReopen = false
        popup.accessibilityEnvironment = LSTPopViewAccessibilityEnvironment(
            reduceMotion: { false }, preferCrossFade: { false }, voiceOverRunning: { true },
            focusedElement: { [weak previousButton] in previousButton },
            screenChanged: { focusEvents.append($0) })
        popup.pop()
        try await popEventually { focusEvents.count == 1 }
        if reason == "reopen" {
            popup.popViewDidDismissBlock = { [weak popup] in
                guard !didReopen else { return }
                didReopen = true
                popup?.pop()
            }
            popup.dismiss()
            try await popEventually { didReopen && focusEvents.count >= 2 }
        } else {
            LSTPopView.invalidateAllScopes()
        }
        defer { popup.popViewDidDismissBlock = nil }
        await popDeliveryTurn()
        await popDeliveryTurn()
        #expect(!focusEvents.contains { $0 === previousButton })
        #expect(focusEvents.allSatisfy { $0 == nil })
        #expect(focusEvents.count == (reason == "reopen" ? 2 : 1))
    }

    @Test("旧弹窗关闭回调展示新模态时，旧延迟恢复不能把焦点抢回底层")
    func oldAccessibilityRestorationCannotStealFocusFromNewPopup() async throws {
        let fixture = try PopWindowFixture()
        defer { fixture.close() }
        // 底层按钮始终可见且仍属于真实window；因此旧恢复任务不能仅靠window存在性判断是否安全。
        let previousButton = UIButton(frame: CGRect(x: 1, y: 1, width: 80, height: 30))
        fixture.parent.addSubview(previousButton)
        let old = try fixture.popup()
        let replacement = try fixture.popup()
        var oldFocusEvents = [AnyObject?]()
        var newFocusEvents = [AnyObject?]()
        old.accessibilityEnvironment = LSTPopViewAccessibilityEnvironment(
            reduceMotion: { false }, preferCrossFade: { false }, voiceOverRunning: { true },
            focusedElement: { [weak previousButton] in previousButton },
            screenChanged: { oldFocusEvents.append($0) })
        replacement.accessibilityEnvironment = LSTPopViewAccessibilityEnvironment(
            reduceMotion: { false }, preferCrossFade: { false }, voiceOverRunning: { true },
            focusedElement: { [weak previousButton] in previousButton },
            screenChanged: { newFocusEvents.append($0) })
        // 使用两个不同对象，专门覆盖同对象transitionID和账号epoch检查均无法排除的旧焦点任务。
        // 弱捕获避免测试回调额外保活新弹窗；实际展示仍由manager按主线程生命周期接管。
        old.popViewDidDismissBlock = { [weak replacement] in replacement?.pop() }
        defer { old.popViewDidDismissBlock = nil }
        old.pop()
        try await popEventually { oldFocusEvents.count == 1 }
        old.dismiss()
        try await popEventually {
            old.superview == nil && replacement.superview === fixture.parent && newFocusEvents.count == 1
        }
        // 旧恢复是下一主队列轮次执行；等待两个交付轮次后才断言，避免在任务运行前得到虚假的通过。
        await popDeliveryTurn()
        await popDeliveryTurn()
        #expect(previousButton.window === fixture.window)
        #expect(replacement.accessibilityViewIsModal)
        #expect(replacement.superview === fixture.parent)
        #expect(oldFocusEvents.count == 1)
        #expect(newFocusEvents.count == 1)
        #expect(oldFocusEvents.allSatisfy { $0 == nil })
        #expect(newFocusEvents.allSatisfy { $0 == nil })
    }

    @Test("减少动态效果与交叉淡化替换运动样式，NO和未开启偏好仍保留原契约")
    func motionPreferencesResolveToAccessibleStyles() {
        #expect(LSTPopViewMotionPolicy.popStyle(.springFromBottom, reduceMotion: true, preferCrossFade: false) == .fade)
        #expect(LSTPopViewMotionPolicy.popStyle(.cardDropFromLeft, reduceMotion: false, preferCrossFade: true) == .fade)
        #expect(LSTPopViewMotionPolicy.popStyle(.NO, reduceMotion: true, preferCrossFade: true) == .NO)
        #expect(LSTPopViewMotionPolicy.popStyle(.smoothFromRight, reduceMotion: false, preferCrossFade: false) == .smoothFromRight)
        #expect(LSTPopViewMotionPolicy.dismissStyle(.cardDropToRight, reduceMotion: true, preferCrossFade: false) == .fade)
        #expect(LSTPopViewMotionPolicy.dismissStyle(.NO, reduceMotion: true, preferCrossFade: true) == .NO)
    }
}
