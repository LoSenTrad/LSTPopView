// LSTPopView 0.3.10 的 Swift 原生移植；保留上游公开类型名称和业务调用拼写。
// 基于 LoSenTrad 的 MIT 许可源码；完整版权与许可见仓库 LICENSE 和 Swift/LICENSE。
// 本目录不调用原 Objective-C 实现，不依赖 LSTTimer 或其它第三方组件。
import UIKit

/// 调试显示模式；原始整数值保持一致，ALL 同时启用小窗和控制台。
public enum LSTPopViewLogStyle: Int, Sendable {
    case no = 0, window, console, all
    public static let NO = Self.no
    public static let ALL = Self.all
}

/// 所有显示动画。无动画仍完成完整生命周期，方向均相对于 parentView 的本地坐标。
public enum LSTPopStyle: Int, Sendable {
    case fade = 0, no, scale
    case smoothFromTop, smoothFromLeft, smoothFromBottom, smoothFromRight
    case springFromTop, springFromLeft, springFromBottom, springFromRight
    case cardDropFromLeft, cardDropFromRight
    public static let NO = Self.no
}

/// 所有消失动画；原整数值和拼写保持兼容。
public enum LSTDismissStyle: Int, Sendable {
    case fade = 0, no, scale
    case smoothToTop, smoothToLeft, smoothToBottom, smoothToRight
    case cardDropToLeft, cardDropToRight, cardDropToTop
    public static let NO = Self.no
}

/// 原库公开但尚未提供执行入口的主动动画枚举，保留类型，不虚构额外 API。
public enum LSTActivityStyle: Int, Sendable { case no = 0, scale, shake; public static let NO = Self.no }

/// 九种贴边方式；adjustX/adjustY 在该定位计算后应用，不改变 customView 自身尺寸。
public enum LSTHemStyle: Int, Sendable { case center = 0, top, left, bottom, right, topLeft, bottomLeft, bottomRight, topRight }

/// 原头文件以位掩码组合拖拽方向，Swift 用 OptionSet 准确表达组合，不丢失多方向能力。
public struct LSTDragStyle: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let NO: Self = []
    public static let no: Self = []
    public static let x_Positive = Self(rawValue: 1 << 0)
    public static let x_Negative = Self(rawValue: 1 << 1)
    public static let y_Positive = Self(rawValue: 1 << 2)
    public static let y_Negative = Self(rawValue: 1 << 3)
    public static let x: Self = [.x_Positive, .x_Negative]
    public static let y: Self = [.y_Positive, .y_Negative]
    public static let all: Self = [.x, .y]
    public static let ALL = Self.all
}

/// 轻扫许可独立于拖拽许可；两个集合同时允许的方向才可以用速度触发消失。
public struct LSTSweepStyle: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let NO: Self = []
    public static let no: Self = []
    public static let x_Positive = Self(rawValue: 1 << 0)
    public static let x_Negative = Self(rawValue: 1 << 1)
    public static let y_Positive = Self(rawValue: 1 << 2)
    public static let y_Negative = Self(rawValue: 1 << 3)
    public static let x: Self = [.x_Positive, .x_Negative]
    public static let y: Self = [.y_Positive, .y_Negative]
    public static let ALL: Self = [.x, .y]
    public static let all = Self.ALL
}

/// velocity 按速度继续飞出，smooth 选择对应方向的平滑消失。
public enum LSTSweepDismissStyle: Int, Sendable { case velocity = 0, smooth }

/// 多代理协议保持原导入 Swift 的 for: 标签。默认空实现允许只关心部分事件，
/// 不需要 NSObject 或 Objective-C 消息转发；弹窗内部只保存弱引用，不延长代理生命。
@MainActor
public protocol LSTPopViewProtocol: AnyObject {
    func lst_PopViewBgClick(for popView: LSTPopView)
    func lst_PopViewBgLongPress(for popView: LSTPopView)
    func lst_PopViewWillPop(for popView: LSTPopView)
    func lst_PopViewDidPop(for popView: LSTPopView)
    func lst_PopViewCountDown(for popView: LSTPopView, forCountDown timeInterval: TimeInterval)
    func lst_PopViewCountDownFinish(for popView: LSTPopView)
    func lst_PopViewWillDismiss(for popView: LSTPopView)
    func lst_PopViewDidDismiss(for popView: LSTPopView)
}

public extension LSTPopViewProtocol {
    func lst_PopViewBgClick(for popView: LSTPopView) {}
    func lst_PopViewBgLongPress(for popView: LSTPopView) {}
    func lst_PopViewWillPop(for popView: LSTPopView) {}
    func lst_PopViewDidPop(for popView: LSTPopView) {}
    func lst_PopViewCountDown(for popView: LSTPopView, forCountDown timeInterval: TimeInterval) {}
    func lst_PopViewCountDownFinish(for popView: LSTPopView) {}
    func lst_PopViewWillDismiss(for popView: LSTPopView) {}
    func lst_PopViewDidDismiss(for popView: LSTPopView) {}
}

/// 库内部的几何辅助属性，不导出到消费方，避免与 OC UIView+LSTPV 分类产生同名 API 歧义。
/// setter 仅改目标分量，保留其余 frame/center 值。
extension UIView {
    var pv_X: CGFloat { get { frame.origin.x } set { frame.origin.x = newValue } }
    var pv_Y: CGFloat { get { frame.origin.y } set { frame.origin.y = newValue } }
    var pv_Width: CGFloat { get { frame.size.width } set { frame.size.width = newValue } }
    var pv_Height: CGFloat { get { frame.size.height } set { frame.size.height = newValue } }
    var pv_CenterX: CGFloat { get { center.x } set { center.x = newValue } }
    var pv_CenterY: CGFloat { get { center.y } set { center.y = newValue } }
    var pv_Top: CGFloat { get { frame.minY } set { frame.origin.y = newValue } }
    var pv_Left: CGFloat { get { frame.minX } set { frame.origin.x = newValue } }
    var pv_Bottom: CGFloat { get { frame.maxY } set { frame.origin.y = newValue - frame.height } }
    var pv_Right: CGFloat { get { frame.maxX } set { frame.origin.x = newValue - frame.width } }
    var pv_Size: CGSize { get { frame.size } set { frame.size = newValue } }
}

/// 旧工厂的兼容入口：只在前台窗口唯一时推断宿主，不从无序 connectedScenes 集合随便选一个。
/// 多个前台 scene 各有 keyWindow 时必须由调用方传 parentView；不把另一账号/页面的内容送到错误窗口。
/// 场景连接但尚未 active 的短暂阶段只允许唯一 foregroundInactive scene，不回退到后台场景。
@MainActor
func lstPopKeyWindow() -> UIWindow? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let active = scenes.filter { $0.activationState == .foregroundActive }
    let foreground = active.isEmpty ? scenes.filter { $0.activationState == .foregroundInactive } : active
    let windows = foreground.flatMap(\.windows).filter { !$0.isHidden && $0.windowLevel == .normal }
    let keys = windows.filter(\.isKeyWindow)
    if keys.count == 1 { return keys[0] }
    if keys.isEmpty && foreground.count == 1 && windows.count == 1 { return windows[0] }
    return nil
}

/// 原全局函数仍被业务使用；判断当前窗口底部安全区，不硬编码设备型号。
@MainActor func pv_IsIphoneX_ALL() -> Bool { (lstPopKeyWindow()?.safeAreaInsets.bottom ?? 0) > 0 }
/// 保留原屏幕尺寸读取函数，供仍依赖此工具类别的调用者使用。
@MainActor func pv_ScreenSize() -> CGSize { UIScreen.main.bounds.size }
@MainActor func pv_ScreenWidth() -> CGFloat { UIScreen.main.bounds.width }
@MainActor func pv_ScreenHeight() -> CGFloat { UIScreen.main.bounds.height }
