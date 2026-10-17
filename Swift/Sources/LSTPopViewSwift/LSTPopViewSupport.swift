// LSTPopView 的纯布局规则、单调时钟和系统可访问性适配。
// UIKit 展示状态留在 LSTPopView；这里把可独立验证的规则与外部系统依赖分离。
// 完整上游版权和 MIT 许可见仓库 LICENSE 和 Swift/LICENSE。
import UIKit

/// 通知回调的值快照：只传递名称、几何、时间、曲线与对象身份，
/// 不保存 Notification、userInfo[AnyHashable: Any] 或 UIScreen 等可变对象。
/// queue.main 保证提取与系统键盘事件同序，Sendable 保证进入 MainActor 的捕获有明确边界。
struct LSTPopViewEnvironmentEvent: Sendable {
    let name: Notification.Name
    let sourceScreenID: ObjectIdentifier?
    let beginFrame: CGRect
    let endFrame: CGRect
    let duration: TimeInterval
    let animationCurve: UInt

    init(_ notification: Notification) {
        name = notification.name
        sourceScreenID = (notification.object as? UIScreen).map(ObjectIdentifier.init)
        let info = notification.userInfo ?? [:]
        beginFrame = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        animationCurve = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
    }
}

/// 只计算值，不访问 UIView、UIApplication 或全局窗口；嵌套容器与旋转使用同一套本地坐标。
enum LSTPopViewLayout {
    /// 保留原九种贴边方式和偏移语义，内容尺寸由业务视图决定，不擅自改动业务约束。
    static func frame(in bounds: CGRect, contentSize size: CGSize, hem: LSTHemStyle, offset: CGPoint) -> CGRect {
        var x = bounds.midX - size.width / 2
        var y = bounds.midY - size.height / 2
        switch hem {
        case .top: y = bounds.minY
        case .left: x = bounds.minX
        case .bottom: y = bounds.maxY - size.height
        case .right: x = bounds.maxX - size.width
        case .topLeft: x = bounds.minX; y = bounds.minY
        case .bottomLeft: x = bounds.minX; y = bounds.maxY - size.height
        case .bottomRight: x = bounds.maxX - size.width; y = bounds.maxY - size.height
        case .topRight: x = bounds.maxX - size.width; y = bounds.minY
        case .center: break
        }
        return CGRect(origin: CGPoint(x: x + offset.x, y: y + offset.y), size: size)
    }

    /// 只有键盘真正遮住内容（或侵入底部预留间距）才移动。
    /// 浮动键盘在内容上方且互不相交时保持原位；移动后保留顶部可见，过高内容不会被整个推走。
    /// 原本由调用方明确配置为负数的顶部偏移仍允许保留，不改变现有业务的手工定位语义。
    static func avoidingKeyboard(_ keyboard: CGRect?, original: CGRect, in bounds: CGRect, spacing: CGFloat) -> CGRect {
        guard let keyboard = keyboard, !keyboard.isNull, !keyboard.isInfinite, !keyboard.isEmpty,
              keyboard.intersects(bounds), keyboard.maxX > original.minX, keyboard.minX < original.maxX,
              keyboard.maxY > original.minY, keyboard.minY < original.maxY + max(0, spacing) else { return original }
        var target = original
        let overlap = max(0, original.maxY + max(0, spacing) - keyboard.minY)
        target.origin.y = max(min(bounds.minY, original.minY), original.minY - overlap)
        return target
    }
}

/// 倒计时只依赖经过的时长，不依赖用户可修改的日历时间。
/// 测试可注入手动时钟推进截止时间，不需要更改设备时间或阻塞主线程。
@MainActor
protocol LSTPopViewClock: AnyObject {
    var now: TimeInterval { get }
}

/// 系统运行时长是单调时间；手动校时、时区变更和网络校时不会延长或提前关闭弹窗。
/// 后台期间不主动唤醒 App；恢复执行后的首个 tick 按已经经过的系统运行时长核算。
@MainActor
final class LSTPopViewSystemClock: LSTPopViewClock {
    static let shared = LSTPopViewSystemClock()
    var now: TimeInterval { ProcessInfo.processInfo.systemUptime }
}

/// 集中适配系统偏好与辅助功能事件。闭包明确属于 MainActor，不将 UIKit 对象发送到后台。
/// 测试可替换这些闭包验证模态和焦点事件，而不打开用户的 VoiceOver 或修改系统偏好。
@MainActor
struct LSTPopViewAccessibilityEnvironment {
    var reduceMotion: @MainActor () -> Bool
    var preferCrossFade: @MainActor () -> Bool
    var voiceOverRunning: @MainActor () -> Bool
    var focusedElement: @MainActor () -> AnyObject?
    var screenChanged: @MainActor (AnyObject?) -> Void

    static let live = Self(
        reduceMotion: { UIAccessibility.isReduceMotionEnabled },
        preferCrossFade: { UIAccessibility.prefersCrossFadeTransitions },
        voiceOverRunning: { UIAccessibility.isVoiceOverRunning },
        focusedElement: { UIAccessibility.focusedElement(using: .notificationVoiceOver) as AnyObject? },
        screenChanged: { UIAccessibility.post(notification: .screenChanged, argument: $0) }
    )
}

/// 统一解析动画偏好：无动画仍为无动画；开启减少动态效果或交叉淡化时，方向/旋转/弹簧改淡化。
/// 只改变运动效果，不改变定位、背景交互、生命周期次数或倒计时起点。
enum LSTPopViewMotionPolicy {
    static func popStyle(_ style: LSTPopStyle, reduceMotion: Bool, preferCrossFade: Bool) -> LSTPopStyle {
        style == .no || !(reduceMotion || preferCrossFade) ? style : .fade
    }
    static func dismissStyle(_ style: LSTDismissStyle, reduceMotion: Bool, preferCrossFade: Bool) -> LSTDismissStyle {
        style == .no || !(reduceMotion || preferCrossFade) ? style : .fade
    }
}
