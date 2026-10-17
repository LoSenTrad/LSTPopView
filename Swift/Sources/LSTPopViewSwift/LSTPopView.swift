// LSTPopView 0.3.10 的纯 Swift/UIKit 移植。完整版权及 MIT 许可见仓库 LICENSE 和 Swift/LICENSE。
// 保留旧业务的可空工厂、属性、方法标签与全部样式，不调用原 Objective-C 类或 LSTTimer。
// 阅读顺序：Types（公开契约）→ Manager（分组队列）→ 本文件（布局/交互/生命周期）。
import UIKit
import QuartzCore

/// Popup 的所有可变状态属于 MainActor。管理器拥有展示会话，UIView 仅负责渲染和交互。
/// 业务保留原工厂/属性接口；入队快照、宿主与账号失效规则由独立的会话管理器处理。
@MainActor
public final class LSTPopView: UIView, UIGestureRecognizerDelegate {
    // MARK: 公开配置：默认值以原 0.3.10 实际源码为准

    /// 设置代理表示添加到弱多代理池，而非覆盖；重复设置同一对象不会重复通知。
    public var delegate: LSTPopViewProtocol? {
        get { delegatePool.compactMap(\.value).last }
        set {
            guard let value = newValue else { return }
            delegatePool.removeAll { $0.value == nil }
            if !delegatePool.contains(where: { $0.value === value }) { delegatePool.append(WeakDelegate(value)) }
        }
    }
    /// 标识用于静态查找/移除；空值不参与按 key 查询，重复标识返回第一个登记窗口。
    public var identifier: String? = ""
    /// 对外保留非可空旧接口；fallback 只用于兼容读取，不能代表一个仍有效的展示宿主。
    /// 队列和实际展示始终使用 configuredParentView，不会把父容器释放后的 popup 重新分组。
    public var parentView: UIView { configuredParentView ?? fallbackContainer }
    var configuredParentView: UIView? { creationContext.parentView }
    /// 工厂创建时捕获账号 epoch 与宿主作用域。账号清场后，即使外界还持有 popup，也不能复用旧内容。
    let creationContext: LSTPopViewCreationContext
    public var isPresentationContextValid: Bool { LSTPopViewManager.shared.isValid(creationContext) }
    /// 业务传入的同一个 UIView，不复制、不替换内部约束；对外只读持有关系。
    public private(set) var currCustomView: UIView
    /// 九种定位方式；改配置后立即按原尺寸重排，现有业务不必额外调用 layoutIfNeeded。
    public var hemStyle = LSTHemStyle.center { didSet { refreshContentLayout() } }
    /// 普通 UIView 初始化默认 fade；只传 customView 的旧工厂明确覆盖为 .no。
    public var popStyle = LSTPopStyle.fade
    public var dismissStyle = LSTDismissStyle.fade
    /// -1 表示按样式取默认时长；属性仅接纳正值，与原 setter 的约束保持一致。
    public var popDuration: TimeInterval { get { storedPopDuration } set { if newValue > 0 { storedPopDuration = newValue } } }
    public var dismissDuration: TimeInterval { get { storedDismissDuration } set { if newValue > 0 { storedDismissDuration = newValue } } }
    /// 偏移加到定位后的 frame；键盘规避以这个未被键盘移动的原始 frame 为基准。
    public var adjustX: CGFloat = 0 { didSet { refreshContentLayout() } }
    public var adjustY: CGFloat = 0 { didSet { refreshContentLayout() } }
    /// 颜色与透明度独立。nil 按透明色处理；bgAlpha 限制 0...1，不改变业务内容透明度。
    public var bgColor: UIColor? = .black { didSet { updateBackdrop() } }
    public var bgAlpha: CGFloat = 0.25 { didSet { bgAlpha = min(1, max(0, bgAlpha)); updateBackdrop() } }
    /// 不只隐藏颜色：背景 hitTest 穿透至下层业务，内容及其按钮仍可接收触摸。
    public var isHideBg = false { didSet { updateBackdrop(); updateAccessibilityModality() } }
    /// 默认背景点击只通知，不移除；打开后按“代理→Block→dismiss”顺序执行。
    public var isClickBgDismiss = false
    /// 外层容器尺寸变化仍铺满背景；关闭后保留原定位，不随旋转重排内容。
    public var isObserverScreenRotation = true
    /// 可选轻触反馈不取消内容控件的点击；默认关闭，保留原业务交互手感。
    public var isClickFeedback = false
    /// 默认规避键盘；重复 frame 通知始终从 originFrame 计算，避免累计向上漂移。
    public var isAvoidKeyboard = true { didSet { refreshContentLayout() } }
    public var avoidKeyboardSpace: CGFloat = 10 { didSet { refreshContentLayout() } }
    /// 正值在 didPop 之后开始；被优先级挂起时暂停，恢复后按剩余时间继续。
    public var showTime: TimeInterval = 0
    /// 指定角的 mask 只在正圆角时创建；尺寸变化时同步更新路径，恢复时不破坏业务原 mask。
    public var rectCorners: UIRectCorner = .allCorners { didSet { updateCorners() } }
    public var cornerRadius: CGFloat = 0 { didSet { updateCorners() } }
    /// 显示完成前可触发中等震动，使用系统 UIKit generator，不增加依赖。
    public var isImpactFeedback = false
    /// 队列隔离还包含 parentView；同名 groupId 在不同父视图之间互不影响。
    public var groupId: String?
    /// 堆叠窗口同时显示，不抢占旧窗口；移除堆叠窗口不唤醒其它队列。
    public var isStack = false
    /// 单显先真正移除同 parent/group 旧窗口，再显示本窗口，优先级不参与此分支。
    public var isSingle = false
    /// 原文档范围 0...1000；读写做截断，排序时相等的新窗按原源码抢占旧窗。
    public var priority: CGFloat = 0 { didSet { priority = min(1000, max(0, priority)) } }
    /// 拖拽方向可组合；NO 不安装额外业务依赖，手势代理会拒绝开始。
    public var dragStyle: LSTDragStyle = .no
    /// 0 表示拖动后回弹；正值表示允许方向的位移达到阈值后消失。
    public var dragDistance: CGFloat = 0
    /// 未显式赋值时跟随 dismissStyle；显式设 .no 也必须可区分于未配置。
    public var dragDismissStyle: LSTDismissStyle {
        get { configuredDragDismissStyle ?? dismissStyle }
        set { configuredDragDismissStyle = newValue }
    }
    /// 未设正值时跟随消失时长；回弹独立使用 dragReboundTime，默认 0.25 秒。
    public var dragDismissDuration: TimeInterval { get { storedDragDismissDuration } set { if newValue > 0 { storedDragDismissDuration = newValue } } }
    public var dragReboundTime: TimeInterval = 0.25
    /// 轻扫必须同时满足 dragStyle 和 sweepStyle，默认两个都禁用。
    public var sweepStyle: LSTSweepStyle = .no
    public var swipeVelocity: CGFloat = 1000
    public var sweepDismissStyle = LSTSweepDismissStyle.velocity

    // MARK: 一次性回调：界面生命周期与键盘信息，不存储业务数据

    public var bgClickBlock: (() -> Void)?
    public var bgLongPressBlock: (() -> Void)?
    /// 当前内容相对未拖动位置的偏移，返回父容器本地坐标，不是累计 translation。
    public var panOffsetBlock: ((CGPoint) -> Void)?
    public var keyboardWillShowBlock: (() -> Void)?
    public var keyboardDidShowBlock: (() -> Void)?
    public var keyboardFrameWillChangeBlock: ((CGRect, CGRect, CGFloat) -> Void)?
    public var keyboardFrameDidChangeBlock: ((CGRect, CGRect, CGFloat) -> Void)?
    public var keyboardWillHideBlock: (() -> Void)?
    public var keyboardDidHideBlock: (() -> Void)?
    public var popViewWillPopBlock: (() -> Void)?
    public var popViewDidPopBlock: (() -> Void)?
    public var popViewWillDismissBlock: (() -> Void)?
    /// 真正移出视图后执行一次，不再等待 dealloc，因此业务强持有已 dismiss 窗也会及时收到通知。
    public var popViewDidDismissBlock: (() -> Void)?
    public var popViewCountDownBlock: ((LSTPopView, TimeInterval) -> Void)?

    /// 内部可注入依赖不暴露在产品界面：测试可以推进单调时间或模拟辅助功能偏好。
    var countdownClock: any LSTPopViewClock = LSTPopViewSystemClock.shared
    var accessibilityEnvironment = LSTPopViewAccessibilityEnvironment.live

    // MARK: 内部所有权与状态机

    enum Phase { case idle, queued, presenting, visible, suspended, dismissing, dismissed }
    private var phase = Phase.idle
    /// 每次显示/挂起/移除推进代际，旧动画 completion 不能关闭或复活新一轮窗口。
    private var transitionID = UUID()
    /// 仅 direct init(frame:) 或父容器已释放时兜底；不创建系统 window。
    private let fallbackContainer: UIView
    private let backdrop = UIView()
    private var delegatePool: [WeakDelegate] = []
    private var storedPopDuration: TimeInterval = -1
    private var storedDismissDuration: TimeInterval = -1
    private var storedDragDismissDuration: TimeInterval = -1
    private var configuredDragDismissStyle: LSTDismissStyle?
    /// 未受键盘/手势影响的目标位置，尺寸变化及旋转后重新计算。
    private var originFrame = CGRect.zero
    private var isUpdatingLayout = false
    private var observedSize = CGSize.zero
    private var sizeObservation: NSKeyValueObservation?
    private var frameObservation: NSKeyValueObservation?
    private var cornerMask: CAShapeLayer?
    private var originalMask: CALayer?
    private var keyboardFrame: CGRect?
    private var notificationTokens: [NSObjectProtocol] = []
    private var panGesture: UIPanGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
    private var longPressGesture: UILongPressGestureRecognizer!
    private weak var touchedScrollView: UIScrollView?
    private var panStartFrame = CGRect.zero
    private var timer: Timer?
    private var deadline: TimeInterval?
    private var remainingTime: TimeInterval = 0
    /// 区分“未设置倒计时”和“倒计时已到 0 但刚好在 tick 前挂起”，后者恢复必须立即结束。
    private var hasCountdown = false
    private var queuedStyle = LSTPopStyle.no
    private var queuedDuration: TimeInterval = -1
    private(set) var hasPoppedBefore = false
    private var didNotifyPop = false
    private var removingInternally = false
    /// 弱保存原焦点，不因为辅助功能恢复而延长旧业务页面寿命。
    private weak var previousAccessibilityElement: AnyObject?

    private final class WeakDelegate {
        weak var value: LSTPopViewProtocol?
        init(_ value: LSTPopViewProtocol) { self.value = value }
    }

    var canEnqueue: Bool { phase == .idle || phase == .dismissed }
    var canResumeFromQueue: Bool { phase == .queued || phase == .suspended }
    var isActuallyPresented: Bool { phase == .presenting || phase == .visible }

    /// 直接 UIView 初始化也建立完整内部结构；正式业务通常使用下方可空工厂。
    public override init(frame: CGRect) {
        let fallback = UIView(frame: frame)
        fallbackContainer = fallback
        creationContext = LSTPopViewManager.shared.captureCreationContext(parent: fallback)
        currCustomView = UIView()
        super.init(frame: frame)
        configureViewHierarchy()
    }

    /// 工厂专用初始化：真实 parent 和创建 epoch 在 super.init 前固定，后续不会换成另一个宿主。
    private init(customView: UIView, parent: UIView, popStyle: LSTPopStyle, dismissStyle: LSTDismissStyle) {
        fallbackContainer = UIView()
        creationContext = LSTPopViewManager.shared.captureCreationContext(parent: parent)
        currCustomView = customView
        super.init(frame: parent.bounds)
        self.popStyle = popStyle
        self.dismissStyle = dismissStyle
        configureViewHierarchy()
        refreshContentLayout()
    }

    public required init?(coder: NSCoder) {
        let fallback = UIView()
        fallbackContainer = fallback
        creationContext = LSTPopViewManager.shared.captureCreationContext(parent: fallback)
        currCustomView = UIView()
        super.init(coder: coder)
        configureViewHierarchy()
    }

    /// 三种初始化共用同一套结构与手势配置，避免 coder/frame/factory 分支行为逐渐不一致。
    private func configureViewHierarchy() {
        backgroundColor = .clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backdrop)
        installContent(currCustomView)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(popViewBgViewTap(_:)))
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(backgroundLongPress(_:)))
        backdrop.addGestureRecognizer(tapGesture)
        backdrop.addGestureRecognizer(longPressGesture)
        tapGesture.delegate = self
        longPressGesture.delegate = self
        updateBackdrop()
        updateAccessibilityModality()
    }

    /// 与 ObjC nullable 工厂兼容；找不到真实 window 时返回 nil，不悄悄创建抢焦点的假 window。
    public static func initWithCustomView(_ customView: UIView) -> LSTPopView? {
        initWithCustomView(customView, parentView: nil, popStyle: .no, dismissStyle: .no)
    }
    public static func initWithCustomView(_ customView: UIView, popStyle: LSTPopStyle, dismissStyle: LSTDismissStyle) -> LSTPopView? {
        initWithCustomView(customView, parentView: nil, popStyle: popStyle, dismissStyle: dismissStyle)
    }
    public static func initWithCustomView(_ customView: UIView, parentView: UIView?, popStyle: LSTPopStyle, dismissStyle: LSTDismissStyle) -> LSTPopView? {
        guard let parent = parentView ?? customView.window ?? lstPopKeyWindow() else { return nil }
        return LSTPopView(customView: customView, parent: parent, popStyle: popStyle, dismissStyle: dismissStyle)
    }

    /// 内容只搬到本弹窗，不改其尺寸/业务约束；弱观察尺寸变化，替换内容时先失效旧观察。
    private func installContent(_ view: UIView) {
        sizeObservation = nil; frameObservation = nil
        currCustomView = view
        originalMask = view.layer.mask
        addSubview(view)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        let feedback = UITapGestureRecognizer(target: self, action: #selector(contentFeedback(_:)))
        feedback.cancelsTouchesInView = false
        view.addGestureRecognizer(feedback)
        observeContentSize()
    }

    /// frame/bounds 任一尺寸变化立即重排。原点变化（包括库自己的拖动/键盘动画）不触发重排。
    private func observeContentSize() {
        observedSize = currCustomView.bounds.size
        sizeObservation = currCustomView.observe(\.bounds, options: [.old, .new]) { [weak self] view, _ in
            // 被观察者是 UIKit UIView，其尺寸写入本身必须在 MainActor。KVO 同步回调沿用这个边界；
            // 不能一概异步派发，否则业务改尺寸后立即读取贴底位置会读到旧结果。
            MainActor.assumeIsolated {
                guard let self = self, view.bounds.size != self.observedSize else { return }
                self.refreshContentLayout()
            }
        }
        frameObservation = currCustomView.observe(\.frame, options: [.old, .new]) { [weak self] view, _ in
            MainActor.assumeIsolated {
                guard let self = self, view.bounds.size != self.observedSize else { return }
                self.refreshContentLayout()
            }
        }
    }

    // MARK: 公开显示/移除 API

    public func pop() { pop(with: popStyle, duration: popDuration) }
    public func pop(with style: LSTPopStyle) { pop(with: style, duration: popDuration) }
    public func pop(withDuration duration: TimeInterval) { pop(with: popStyle, duration: duration) }
    /// 单次样式/时长只影响本次，不回写全局属性；重复 pop 不重复登记和回调。
    public func pop(with style: LSTPopStyle, duration: TimeInterval) {
        LSTPopViewManager.shared.enqueue(self, style: style, duration: duration)
    }
    public func dismiss() { dismiss(with: dismissStyle, duration: dismissDuration) }
    public func dismiss(with style: LSTDismissStyle) { dismiss(with: style, duration: dismissDuration) }
    public func dismiss(withDuration duration: TimeInterval) { dismiss(with: dismissStyle, duration: duration) }
    /// 移除在真正动画结束后完成；重复 dismiss、旧动画 completion 和外部 remove 共享一次性门闩。
    public func dismiss(with style: LSTDismissStyle, duration: TimeInterval) {
        LSTPopViewManager.shared.cancelPending(self)
        guard phase != .idle, phase != .dismissed, phase != .dismissing else { return }
        phase = .dismissing
        transitionID = UUID()
        let id = transitionID
        stopTimer(preservingRemaining: false)
        endEditing(true)
        delegates(in: id) { $0.lst_PopViewWillDismiss(for: self) }
        guard phase == .dismissing, transitionID == id else { return }
        popViewWillDismissBlock?()
        guard phase == .dismissing, transitionID == id else { return }
        let style = resolvedDismissStyle(style)
        let time = effectiveDismissDuration(style: style, requested: duration)
        if superview == nil || time == 0 { finishRemoval(); return }
        animateDismiss(style: style, duration: time) { [weak self] in
            guard let self = self, self.phase == .dismissing, self.transitionID == id else { return }
            self.finishRemoval()
        }
    }

    /// 外部直接 removeFromSuperview 也要取消 Timer/通知、释放队列并只发一次移除生命周期。
    public override func removeFromSuperview() {
        LSTPopViewManager.shared.cancelPending(self)
        if removingInternally || phase == .idle || phase == .dismissed { super.removeFromSuperview(); return }
        if phase != .dismissing {
            phase = .dismissing
            transitionID = UUID()
            let id = transitionID
            delegates(in: id) { $0.lst_PopViewWillDismiss(for: self) }
            guard phase == .dismissing, transitionID == id else { return }
            popViewWillDismissBlock?()
            // willDismiss 可能再次 remove，didDismiss 又可能重新 pop 本对象；
            // 外层旧移除必须止步，不能继续 finishRemoval 杀掉回调创建的新会话。
            guard phase == .dismissing, transitionID == id else { return }
        }
        finishRemoval()
    }

    /// 账号/宿主失效是强制收尾，不能被“正在 dismiss”幂等门闩挡住。
    /// 同步完成移除并推进动画代际；正在执行的旧动画、计时和键盘回调随后均只能返回。
    /// 已经发过 willDismiss 的窗口不重复发送；批量操作中的重新 pop 会被管理器屏障拒绝。
    func forceRemoveForInvalidation() {
        LSTPopViewManager.shared.cancelPending(self)
        guard phase != .dismissed else { return }
        if phase != .dismissing {
            phase = .dismissing
            transitionID = UUID()
            let id = transitionID
            stopTimer(preservingRemaining: false)
            endEditing(true)
            delegates(in: id) { $0.lst_PopViewWillDismiss(for: self) }
            guard phase == .dismissing, transitionID == id else { return }
            popViewWillDismissBlock?()
            guard phase == .dismissing, transitionID == id else { return }
        }
        finishRemoval()
    }

    /// 管理器登记时冻结本次入场配置，等待期间不会借用另一弹窗或后续全局属性的动画。
    func prepareQueuedPresentation(style: LSTPopStyle, duration: TimeInterval) {
        queuedStyle = style; queuedDuration = duration
        hasPoppedBefore = false; didNotifyPop = false
        remainingTime = max(0, showTime)
        hasCountdown = showTime > 0
        phase = .queued
    }

    /// 从队列显示/恢复。挂起不重复 willPop，首次入场若被打断则在真正显示完成时补一次 didPop。
    func performQueuedPresentation(resuming: Bool) {
        guard canResumeFromQueue else { return }
        guard isPresentationContextValid, let parent = configuredParentView else {
            forceRemoveForInvalidation()
            return
        }
        phase = .presenting
        transitionID = UUID()
        let id = transitionID
        frame = parent.bounds
        if superview == nil { parent.addSubview(self) }
        isHidden = false; alpha = 1
        currCustomView.layer.removeAllAnimations()
        currCustomView.transform = .identity
        currCustomView.alpha = 1
        refreshContentLayout()
        registerNotifications()
        if !hasPoppedBefore {
            hasPoppedBefore = true
            if !isHideBg { previousAccessibilityElement = accessibilityEnvironment.focusedElement() }
            delegates(in: id) { $0.lst_PopViewWillPop(for: self) }
            guard phase == .presenting, transitionID == id else { return }
            popViewWillPopBlock?()
        }
        guard phase == .presenting, transitionID == id else { return }
        if isImpactFeedback { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
        let style = resolvedPopStyle(resuming ? .fade : queuedStyle)
        let duration = effectivePopDuration(style: style, requested: resuming ? 0.2 : queuedDuration)
        animatePop(style: style, duration: duration) { [weak self] in
            guard let self = self, self.phase == .presenting, self.transitionID == id else { return }
            self.phase = .visible
            if !self.didNotifyPop {
                self.didNotifyPop = true
                self.delegates(in: id) { $0.lst_PopViewDidPop(for: self) }
                guard self.phase == .visible, self.transitionID == id else { return }
                self.popViewDidPopBlock?()
            }
            if self.phase == .visible && self.transitionID == id {
                self.announceAccessiblePresentation()
                if self.phase == .visible && self.transitionID == id { self.startTimer() }
            }
        }
    }

    /// 挂起是队列内部状态，不是销毁：不发 dismiss 生命周期、不移除登记，暂停剩余倒计时。
    func suspendForQueue() {
        guard isActuallyPresented else { return }
        phase = .suspended; transitionID = UUID()
        stopTimer(preservingRemaining: true)
        endEditing(true)
        keyboardFrame = nil
        unregisterNotifications()
        layer.removeAllAnimations(); currCustomView.layer.removeAllAnimations()
        removingInternally = true; super.removeFromSuperview(); removingInternally = false
    }

    /// 真正移除的唯一出口。先停止资源，再由管理器事务移除登记、发送旧完成事件，最后恢复队列。
    /// 完成通知不能落在同一对象的新一轮 willPop/didPop 之后，否则旧业务收尾会污染新会话。
    private func finishRemoval() {
        guard phase != .dismissed else { return }
        phase = .dismissed; transitionID = UUID()
        stopTimer(preservingRemaining: false)
        unregisterNotifications()
        keyboardFrame = nil
        layer.removeAllAnimations(); currCustomView.layer.removeAllAnimations()
        removingInternally = true; super.removeFromSuperview(); removingInternally = false
        let id = transitionID
        LSTPopViewManager.shared.didRemove(self) {
            self.delegates(in: id) { $0.lst_PopViewDidDismiss(for: self) }
            guard self.phase == .dismissed, self.transitionID == id else { return }
            self.popViewDidDismissBlock?()
        }
        restoreAccessibleFocus(after: id)
    }

    // MARK: 布局、遮罩、圆角与时长

    public override func layoutSubviews() {
        super.layoutSubviews()
        backdrop.frame = bounds
        if isObserverScreenRotation || observedSize != currCustomView.bounds.size { refreshContentLayout() }
    }

    /// 全部定位只使用父视图本地 bounds，嵌套容器/横屏不错误使用全局屏幕尺寸。
    private func refreshContentLayout() {
        guard !isUpdatingLayout else { return }
        isUpdatingLayout = true
        defer { isUpdatingLayout = false }
        backdrop.frame = bounds
        let size = currCustomView.bounds.size
        observedSize = size
        originFrame = LSTPopViewLayout.frame(in: bounds, contentSize: size, hem: hemStyle,
                                            offset: CGPoint(x: adjustX, y: adjustY))
        // 动画/手势只移动位置；尺寸变化时重算基准，键盘恢复永远回到这个新基准。
        if currCustomView.transform == .identity { currCustomView.frame = keyboardAdjustedFrame() }
        updateCorners()
    }

    private func keyboardAdjustedFrame() -> CGRect {
        guard isAvoidKeyboard else { return originFrame }
        return LSTPopViewLayout.avoidingKeyboard(keyboardFrame, original: originFrame, in: bounds,
                                                spacing: avoidKeyboardSpace)
    }

    private func updateBackdrop() {
        backdrop.backgroundColor = (bgColor ?? .clear).withAlphaComponent(isHideBg ? 0 : bgAlpha)
    }

    /// 默认遮罩阻挡下层操作，辅助功能也应采用相同模态语义；透明穿透面板仍允许导航到底层。
    private func updateAccessibilityModality() { accessibilityViewIsModal = !isHideBg }

    private func announceAccessiblePresentation() {
        guard !isHideBg, accessibilityEnvironment.voiceOverRunning() else { return }
        // nil 让系统从模态内容中选择首个可访问元素；不强行把容器本身变成一个不可操作的大元素。
        accessibilityEnvironment.screenChanged(nil)
    }

    /// 等恢复队列完成一个主队列轮次后再找原焦点，避免焦点指向尚未重新挂载的父弹窗。
    /// 旧账号/宿主已经失效、或同一对象已重新 pop 时不再恢复旧焦点。
    private func restoreAccessibleFocus(after id: UUID) {
        guard !isHideBg, accessibilityEnvironment.voiceOverRunning(), previousAccessibilityElement != nil else { return }
        DispatchQueue.main.async { [self] in
            guard phase == .dismissed, transitionID == id, isPresentationContextValid,
                  let element = previousAccessibilityElement else { return }
            if let view = element as? UIView, view.window == nil || view.isHidden { return }
            // 另一个模态弹窗可能已经显示/恢复；只把焦点还给该弹窗内部的原元素，
            // 不允许旧窗口的延迟恢复越过新模态，重新聚焦到底层页面或另一个 window。
            guard LSTPopViewManager.shared.allowsAccessibilityFocusRestoration(to: element) else { return }
            accessibilityEnvironment.screenChanged(element)
            previousAccessibilityElement = nil
        }
    }

    private func resolvedPopStyle(_ style: LSTPopStyle) -> LSTPopStyle {
        LSTPopViewMotionPolicy.popStyle(style, reduceMotion: accessibilityEnvironment.reduceMotion(),
                                        preferCrossFade: accessibilityEnvironment.preferCrossFade())
    }
    private func resolvedDismissStyle(_ style: LSTDismissStyle) -> LSTDismissStyle {
        LSTPopViewMotionPolicy.dismissStyle(style, reduceMotion: accessibilityEnvironment.reduceMotion(),
                                            preferCrossFade: accessibilityEnvironment.preferCrossFade())
    }

    private func updateCorners() {
        if cornerRadius > 0 && !rectCorners.isEmpty {
            let mask = cornerMask ?? CAShapeLayer()
            mask.frame = currCustomView.bounds
            mask.path = UIBezierPath(roundedRect: currCustomView.bounds, byRoundingCorners: rectCorners,
                                     cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            cornerMask = mask
            currCustomView.layer.mask = mask
        } else if currCustomView.layer.mask === cornerMask {
            currCustomView.layer.mask = originalMask
            cornerMask = nil
        }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if isHideBg && (hit === self || hit === backdrop) { return nil }
        return hit
    }

    /// 采用原各样式默认值；单次显式正时长优先，无动画始终 0，不误用全局样式判断局部动画。
    private func effectivePopDuration(style: LSTPopStyle, requested: TimeInterval) -> TimeInterval {
        if style == .no { return 0 }
        if requested > 0 { return requested }
        if style == .fade { return 0.2 }
        if style == .scale { return 0.3 }
        return 0.6
    }
    private func effectiveDismissDuration(style: LSTDismissStyle, requested: TimeInterval) -> TimeInterval {
        if style == .no { return 0 }
        if requested > 0 { return requested }
        if style == .fade { return 0.2 }
        if style == .scale { return 0.3 }
        return 0.5
    }

    // MARK: 全部入场/出场动画

    private func animatePop(style: LSTPopStyle, duration: TimeInterval,
                            completion: @escaping @MainActor @Sendable () -> Void) {
        let target = keyboardAdjustedFrame()
        currCustomView.frame = target
        backdrop.backgroundColor = .clear
        if duration == 0 { updateBackdrop(); completion(); return }
        var spring: CGFloat = 1
        switch style {
        case .fade: currCustomView.alpha = 0
        case .scale: currCustomView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01); spring = 0.65
        case .smoothFromTop, .springFromTop: currCustomView.frame.origin.y = -target.height
        case .smoothFromLeft, .springFromLeft: currCustomView.frame.origin.x = -target.width
        case .smoothFromBottom, .springFromBottom: currCustomView.frame.origin.y = bounds.height
        case .smoothFromRight, .springFromRight: currCustomView.frame.origin.x = bounds.width
        case .cardDropFromLeft, .cardDropFromRight:
            currCustomView.frame.origin.y = -target.height
            currCustomView.transform = CGAffineTransform(rotationAngle: style == .cardDropFromLeft ? .pi / 12 : -.pi / 12)
            spring = 0.75
        case .no: break
        }
        if [.springFromTop, .springFromLeft, .springFromBottom, .springFromRight].contains(style) { spring = 0.65 }
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: spring, initialSpringVelocity: 1,
                       options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]) {
            self.currCustomView.transform = .identity
            self.currCustomView.frame = target
            self.currCustomView.alpha = 1
            self.updateBackdrop()
        } completion: { _ in MainActor.assumeIsolated { completion() } }
    }

    private func animateDismiss(style: LSTDismissStyle, duration: TimeInterval,
                                completion: @escaping @MainActor @Sendable () -> Void) {
        let target = currCustomView.frame
        // 顶部卡片先下沉 50 再飞出；其余样式在一次 UIKit 动画中到达最终模型状态。
        if style == .cardDropToTop {
            UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.beginFromCurrentState]) {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) { self.currCustomView.center.y += 50 }
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.8) {
                    self.currCustomView.frame.origin.y = -target.height
                    self.backdrop.backgroundColor = .clear
                }
            } completion: { _ in MainActor.assumeIsolated { completion() } }
            return
        }
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]) {
            self.backdrop.backgroundColor = .clear
            switch style {
            case .fade, .no: self.currCustomView.alpha = 0
            case .scale: self.currCustomView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01); self.currCustomView.alpha = 0
            case .smoothToTop: self.currCustomView.frame.origin.y = -target.height
            case .smoothToLeft: self.currCustomView.frame.origin.x = -target.width
            case .smoothToBottom: self.currCustomView.frame.origin.y = self.bounds.height
            case .smoothToRight: self.currCustomView.frame.origin.x = self.bounds.width
            case .cardDropToLeft, .cardDropToRight:
                self.currCustomView.center.y = self.bounds.height + target.height
                self.currCustomView.transform = CGAffineTransform(rotationAngle: style == .cardDropToLeft ? .pi / 4 : -.pi / 4)
            case .cardDropToTop: break
            }
        } completion: { _ in MainActor.assumeIsolated { completion() } }
    }

    // MARK: 多代理、背景手势与计时

    private func delegates(in id: UUID? = nil, _ action: (LSTPopViewProtocol) -> Void) {
        delegatePool.removeAll { $0.value == nil }
        // 回调可能添加/删除代理，先取得强快照，避免边遍历边修改池。
        // 每个代理都可重入，而不仅仅是一批代理结束后；前一个代理切换会话后停止交付旧事件。
        for delegate in delegatePool.compactMap(\.value) {
            if let id = id, transitionID != id { break }
            action(delegate)
        }
    }
    public func remove(forDelegate delegate: LSTPopViewProtocol) { delegatePool.removeAll { $0.value == nil || $0.value === delegate } }
    public func remove(for delegate: LSTPopViewProtocol) { remove(forDelegate: delegate) }
    public func removeAllDelegate() { delegatePool.removeAll() }

    /// 保留原 selector，测试/旧动态调用也可触发；真实手势只装在内容背后的独立背景上。
    @objc public func popViewBgViewTap(_ gesture: UIGestureRecognizer) {
        guard isActuallyPresented else { return }
        let id = transitionID
        delegates(in: id) { $0.lst_PopViewBgClick(for: self) }
        guard isActuallyPresented, transitionID == id else { return }
        bgClickBlock?()
        guard isActuallyPresented, transitionID == id else { return }
        if isClickBgDismiss { dismiss() }
    }
    @objc private func backgroundLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, isActuallyPresented else { return }
        let id = transitionID
        delegates(in: id) { $0.lst_PopViewBgLongPress(for: self) }
        guard isActuallyPresented, transitionID == id else { return }
        bgLongPressBlock?()
    }
    @objc private func contentFeedback(_ gesture: UITapGestureRecognizer) {
        if isClickFeedback { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    }

    /// Timer 进 runloop.common，滚动列表时也倒计时；闭包弱捕获，Timer 不延长弹窗生命。
    private func startTimer() {
        guard hasCountdown, timer == nil else { return }
        if remainingTime <= 0 {
            // 截止时间到达但尚未来得及 tick 就被抢占，恢复后应发完成并关闭，而非永久停留。
            deadline = countdownClock.now
            countdownTick()
            return
        }
        deadline = countdownClock.now + remainingTime
        let timer = Timer(timeInterval: min(0.1, remainingTime), repeats: true) { [weak self] _ in
            // Timer 明确添加到 main runloop；在该已证明边界恢复 MainActor 隔离，避免把
            // Foundation 的非隔离 callback 签名误当成可从后台调用 UIKit/代理的许可。
            MainActor.assumeIsolated { self?.countdownTick() }
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    private func countdownTick() {
        guard phase == .visible, let deadline = deadline else { return }
        let id = transitionID
        let remaining = max(0, deadline - countdownClock.now)
        popViewCountDownBlock?(self, remaining)
        guard phase == .visible, transitionID == id else { return }
        delegates(in: id) { $0.lst_PopViewCountDown(for: self, forCountDown: remaining) }
        // 计时回调允许业务手动 dismiss；回调后再次检查，不能再发送一次 finish 或移除新会话。
        guard phase == .visible, transitionID == id else { return }
        if remaining <= 0 {
            stopTimer(preservingRemaining: false)
            delegates(in: id) { $0.lst_PopViewCountDownFinish(for: self) }
            guard phase == .visible, transitionID == id else { return }
            dismiss()
        }
    }
    private func stopTimer(preservingRemaining: Bool) {
        if preservingRemaining, let deadline = deadline { remainingTime = max(0, deadline - countdownClock.now) }
        else if !preservingRemaining { remainingTime = 0 }
        timer?.invalidate(); timer = nil; deadline = nil
    }

    // MARK: 键盘、旋转与滚动内容拖拽协作

    private func registerNotifications() {
        guard notificationTokens.isEmpty else { return }
        let center = NotificationCenter.default
        let names = [UIResponder.keyboardWillShowNotification, UIResponder.keyboardDidShowNotification,
                     UIResponder.keyboardWillChangeFrameNotification, UIResponder.keyboardDidChangeFrameNotification,
                     UIResponder.keyboardWillHideNotification, UIResponder.keyboardDidHideNotification,
                     UIDevice.orientationDidChangeNotification]
        notificationTokens = names.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] notification in
                // OperationQueue.main 是已明确的交付边界；保留与 UIKit 键盘动画同步的执行顺序。
                // Notification 的 userInfo 可含任意可变引用；先提取不可变 Sendable 值，
                // 再进入隔离闭包，不把原始通知及其 Any 字典跨隔离边界捕获。
                let event = LSTPopViewEnvironmentEvent(notification)
                MainActor.assumeIsolated { self?.handleEnvironment(event) }
            }
        }
    }
    private func unregisterNotifications() {
        notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
        notificationTokens.removeAll()
    }
    private func handleEnvironment(_ event: LSTPopViewEnvironmentEvent) {
        guard isActuallyPresented else { return }
        let id = transitionID
        if event.name == UIDevice.orientationDidChangeNotification {
            if isObserverScreenRotation, let parent = configuredParentView { frame = parent.bounds; refreshContentLayout() }
            return
        }
        // iOS 16.1 及以后，键盘通知的 object 可提供来源 UIScreen；外部屏幕的坐标不能当成本屏幕。
        if let sourceScreenID = event.sourceScreenID, let ownScreen = window?.screen,
           sourceScreenID != ObjectIdentifier(ownScreen) { return }
        let begin = event.beginFrame
        let end = event.endFrame
        let duration = event.duration
        switch event.name {
        case UIResponder.keyboardWillShowNotification:
            keyboardWillShowBlock?()
            guard isActuallyPresented, transitionID == id else { return }
            keyboardFrame = keyboardRectInLocalCoordinates(end)
        case UIResponder.keyboardDidShowNotification:
            keyboardDidShowBlock?()
        case UIResponder.keyboardWillChangeFrameNotification:
            keyboardFrameWillChangeBlock?(begin, end, CGFloat(duration))
            guard isActuallyPresented, transitionID == id else { return }
            keyboardFrame = keyboardRectInLocalCoordinates(end)
        case UIResponder.keyboardDidChangeFrameNotification:
            keyboardFrameDidChangeBlock?(begin, end, CGFloat(duration))
        case UIResponder.keyboardWillHideNotification:
            keyboardWillHideBlock?()
            guard isActuallyPresented, transitionID == id else { return }
            keyboardFrame = nil
        case UIResponder.keyboardDidHideNotification:
            keyboardDidHideBlock?()
            guard isActuallyPresented, transitionID == id else { return }
            keyboardFrame = nil
        default: break
        }
        guard isActuallyPresented, transitionID == id, isAvoidKeyboard else { return }
        let curve = event.animationCurve
        UIView.animate(withDuration: max(0, duration), delay: 0,
                       options: [UIView.AnimationOptions(rawValue: curve << 16), .beginFromCurrentState]) {
            self.currCustomView.frame = self.keyboardAdjustedFrame()
        }
    }

    /// 系统键盘通知是屏幕坐标，nil UIView 转换仅指 window 坐标，两者在非零 frame 的
    /// window/多窗口中不同。先从所属屏幕的 coordinateSpace 转到 window，再转到本弹窗。
    private func keyboardRectInLocalCoordinates(_ screenFrame: CGRect) -> CGRect {
        guard let window = window else { return screenFrame }
        let windowFrame = window.convert(screenFrame, from: window.screen.coordinateSpace)
        return convert(windowFrame, from: window)
    }

    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGesture {
            guard isActuallyPresented, !dragStyle.isEmpty else { return false }
            // 滚动内容尚未到顶部时让列表继续滚；到顶部向下时才把手势交给外层弹窗。
            if let scroll = touchedScrollView, scroll.contentOffset.y > -scroll.adjustedContentInset.top { return false }
        }
        return true
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer === panGesture {
            touchedScrollView = nil
            var view = touch.view
            while let candidate = view, candidate !== currCustomView {
                if let scroll = candidate as? UIScrollView { touchedScrollView = scroll; break }
                view = candidate.superview
            }
        }
        return true
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer === panGesture && otherGestureRecognizer.view is UIScrollView
    }
    @objc private func pan(_ gesture: UIPanGestureRecognizer) {
        guard isActuallyPresented, !dragStyle.isEmpty else { return }
        let id = transitionID
        if gesture.state == .began { panStartFrame = currCustomView.frame }
        let translation = gesture.translation(in: self)
        var offset = CGPoint.zero
        if translation.x >= 0 && dragStyle.contains(.x_Positive) || translation.x < 0 && dragStyle.contains(.x_Negative) { offset.x = translation.x }
        if translation.y >= 0 && dragStyle.contains(.y_Positive) || translation.y < 0 && dragStyle.contains(.y_Negative) { offset.y = translation.y }
        if let scroll = touchedScrollView {
            if offset.y > 0 && scroll.contentOffset.y <= -scroll.adjustedContentInset.top { scroll.contentOffset.y = -scroll.adjustedContentInset.top }
            else { offset = .zero }
        }
        currCustomView.frame = panStartFrame.offsetBy(dx: offset.x, dy: offset.y)
        panOffsetBlock?(offset)
        guard isActuallyPresented, transitionID == id else { return }
        guard gesture.state == .ended || gesture.state == .cancelled else { return }
        let velocity = gesture.velocity(in: self)
        let canSweepX = abs(velocity.x) >= max(0, swipeVelocity) &&
            (velocity.x > 0 ? dragStyle.contains(.x_Positive) && sweepStyle.contains(.x_Positive) : dragStyle.contains(.x_Negative) && sweepStyle.contains(.x_Negative))
        let canSweepY = abs(velocity.y) >= max(0, swipeVelocity) &&
            (velocity.y > 0 ? dragStyle.contains(.y_Positive) && sweepStyle.contains(.y_Positive) : dragStyle.contains(.y_Negative) && sweepStyle.contains(.y_Negative))
        if gesture.state != .cancelled && (canSweepX || canSweepY) {
            let style: LSTDismissStyle = canSweepX ? (velocity.x > 0 ? .smoothToRight : .smoothToLeft) : (velocity.y > 0 ? .smoothToBottom : .smoothToTop)
            let speed = max(abs(velocity.x), abs(velocity.y))
            let duration = sweepDismissStyle == .velocity ? min(0.5, max(0.08, max(bounds.width, bounds.height) / max(1, speed))) : dismissDuration
            dismiss(with: style, duration: duration)
        } else if gesture.state != .cancelled && dragDistance > 0 && max(abs(offset.x), abs(offset.y)) >= dragDistance {
            dismiss(with: dragDismissStyle, duration: storedDragDismissDuration > 0 ? storedDragDismissDuration : dismissDuration)
        } else {
            UIView.animate(withDuration: max(0, dragReboundTime), delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
                self.currCustomView.frame = self.keyboardAdjustedFrame()
            }
        }
    }

    // MARK: 静态管理 API，兼容原导入 Swift 的标签

    public static func getAllPopView() -> [LSTPopView] { LSTPopViewManager.shared.items }
    public static func getAllPopView(forParentView parentView: UIView) -> [LSTPopView] { LSTPopViewManager.shared.popups(in: parentView) }
    public static func getAllPopView(for popView: UIView) -> [LSTPopView] {
        guard let popup = popView as? LSTPopView else { return [] }
        return LSTPopViewManager.shared.peers(of: popup)
    }
    public static func getPopView(forKey key: String) -> LSTPopView? {
        guard !key.isEmpty else { return nil }
        return getAllPopView().first { $0.identifier == key }
    }
    public static func removePopView(_ popView: LSTPopView) { popView.dismiss(with: .no, duration: 0) }
    public static func removePopView(forKey key: String) { getPopView(forKey: key)?.dismiss(with: .no, duration: 0) }
    public static func removeAllPopView() { LSTPopViewManager.shared.removeAll() }
    /// 账号退出/切换前撤销全部旧创建上下文；此后旧 popup 即使被持有也不能重新展示。
    public static func invalidateAllScopes() { LSTPopViewManager.shared.invalidateAllScopes() }
    /// 场景断开只撤销该场景的宿主，不关闭其它 windowScene 中仍有效的弹窗。
    public static func invalidatePopViews(in scene: UIScene) { LSTPopViewManager.shared.invalidateScopes(in: scene) }
    public static func removeLastPopView() { LSTPopViewManager.shared.removeLast() }
    public static func setLogStyle(_ logStyle: LSTPopViewLogStyle) { LSTPopViewManager.shared.logStyle = logStyle }

    // 公开 MainActor 类型可以被其它任务持有，最后一次 release 不一定来自主线程。
    // Swift 6.2 的隔离析构确保 UIKit/KVO/主 RunLoop Timer 始终在本 Actor 上清理。
    isolated deinit {
        timer?.invalidate()
        notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
        sizeObservation?.invalidate(); frameObservation?.invalidate()
    }
}
