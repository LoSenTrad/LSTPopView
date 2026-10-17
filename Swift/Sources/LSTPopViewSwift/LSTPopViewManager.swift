// 管理器拥有不可变的一轮 Session，避免可变配置改变已经入队的身份。
// MainActor 解决跨线程写入，事务/意图队列另外处理主线程同步回调重入。
import UIKit
import ObjectiveC

/// 仅保存 UUID，不反向持有宿主；析构后主线程清理，包括没有 superview 的等待窗口。
private final class LSTPopHostLifetimeSentinel {
    let scopeID: UUID
    init(scopeID: UUID) { self.scopeID = scopeID }
    deinit {
        let id = scopeID
        DispatchQueue.main.async { LSTPopViewManager.shared.invalidateReleasedHost(scopeID: id) }
    }
}
@MainActor private var lstPopHostAssociationKey: UInt8 = 0

@MainActor
final class LSTPopViewManager {
    static let shared = LSTPopViewManager()
    /// 唯一强所有权保存登记 Session；移除和失效后必须释放显示及排队窗口。
    private var sessions: [LSTPopViewSession] = []
    var items: [LSTPopView] { sessions.map(\.popup) }
    /// 字典里的 scope 只弱持有 UIView，地址复用也不能复用关联的 UUID。
    private var hostScopes: [UUID: LSTPopViewHostScope] = [:]
    /// 入队或创建时已知的实际 scene。父视图暂时 detached 时不丢失所属 scene 的安全边界。
    private var knownHostScenes: [UUID: ObjectIdentifier] = [:]
    private var hostInvalidationDepth: [UUID: Int] = [:]
    /// 清场最后才推进 epoch，使清场回调中创建的对象也永久无效。
    private var creationEpoch: UInt64 = 0
    private var sceneEpochs: [ObjectIdentifier: UInt64] = [:]
    private var invalidatingAllScopes = false
    private var invalidatingScenes = Set<ObjectIdentifier>()
    /// 全移除期间拒绝回调入场；普通 removeAll 不永久失效 context。
    private var enqueueBarrierDepth = 0
    /// 必须完整发送旧 didDismiss，再处理新意图/队列恢复。
    private var transactionDepth = 0
    /// 嵌套清场返回后，外层旧生命周期回调中新建的对象仍属于旧事务，不借新 epoch 逃逸。
    private var transactionCreationEpoch: UInt64?
    private var transactionSceneEpochs: [ObjectIdentifier: UInt64]?
    private var isDraining = false
    private struct Intent {
        let session: LSTPopViewSession
        let style: LSTPopStyle
        let duration: TimeInterval
    }
    private var pendingEnqueues: [Intent] = []
    private var groupsNeedingResume = Set<LSTPopViewSession.GroupKey>()
    private var showHistory: [WeakPopup] = []
    var logStyle = LSTPopViewLogStyle.no { didSet { updateDebugInfo() } }
    private var debugLabel: UILabel?
    private final class WeakPopup {
        weak var value: LSTPopView?
        init(_ value: LSTPopView) { self.value = value }
    }

    // MARK: 创建上下文与宿主生命周期

    /// 工厂初始化捕获一次。同 UIView 新账户获取新 epoch，旧 context 永不刷新。
    func captureCreationContext(parent: UIView) -> LSTPopViewCreationContext {
        let sentinel: LSTPopHostLifetimeSentinel
        if let existing = objc_getAssociatedObject(parent, &lstPopHostAssociationKey) as? LSTPopHostLifetimeSentinel {
            sentinel = existing
        } else {
            sentinel = LSTPopHostLifetimeSentinel(scopeID: UUID())
            objc_setAssociatedObject(parent, &lstPopHostAssociationKey, sentinel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        let scene = (parent as? UIWindow)?.windowScene ?? parent.window?.windowScene
        let actualSceneID = scene.map(ObjectIdentifier.init)
        if let actualSceneID = actualSceneID { knownHostScenes[sentinel.scopeID] = actualSceneID }
        let sceneID = actualSceneID ?? knownHostScenes[sentinel.scopeID]
        let scope: LSTPopViewHostScope
        if let existing = hostScopes[sentinel.scopeID], !existing.retired, existing.sceneID == sceneID {
            scope = existing
        } else {
            scope = LSTPopViewHostScope(id: sentinel.scopeID, parentView: parent, sceneID: sceneID)
            hostScopes[sentinel.scopeID] = scope
        }
        let scenesAtCreation = transactionSceneEpochs ?? sceneEpochs
        return LSTPopViewCreationContext(scope: scope, creationEpoch: transactionCreationEpoch ?? creationEpoch,
                                         sceneEpoch: sceneID.map { scenesAtCreation[$0, default: 0] } ?? 0)
    }

    /// Core 的焦点、动画和事件入口使用同一有效性判断，不以 fallback 容器复活旧窗口。
    func isValid(_ context: LSTPopViewCreationContext) -> Bool {
        guard !invalidatingAllScopes, !context.scope.retired, context.parentView != nil,
              hostInvalidationDepth[context.scopeID, default: 0] == 0,
              context.creationEpoch == creationEpoch else { return false }
        if let sceneID = context.sceneID {
            return !invalidatingScenes.contains(sceneID) && context.sceneEpoch == sceneEpochs[sceneID, default: 0]
        }
        return true
    }

    /// Sentinel 析构后的主线程入口。排队者从未进入父树，也能在此解除 manager 所有权。
    func invalidateReleasedHost(scopeID: UUID) {
        transaction {
            self.hostScopes[scopeID]?.retired = true
            self.hostScopes.removeValue(forKey: scopeID)
            self.knownHostScenes.removeValue(forKey: scopeID)
            self.hostInvalidationDepth.removeValue(forKey: scopeID)
            self.pendingEnqueues.removeAll { $0.session.context.scopeID == scopeID }
            let affected = self.sessions.filter { $0.context.scopeID == scopeID }
            affected.forEach { $0.context.scope.retired = true }
            affected.forEach { $0.popup.forceRemoveForInvalidation() }
            self.groupsNeedingResume = self.groupsNeedingResume.filter { $0.scopeID != scopeID }
        }
    }

    // MARK: 查询与可重入事务

    func popups(in parent: UIView) -> [LSTPopView] {
        sessions.filter { $0.context.parentView === parent }.map(\.popup)
    }
    /// 已登记者使用本轮快照；未登记者才使用当前公开 groupId。parent 身份始终取 context。
    func peers(of popup: LSTPopView) -> [LSTPopView] {
        let key = sessions.first(where: { $0.popup === popup })?.groupKey
            ?? pendingEnqueues.first(where: { $0.session.popup === popup })?.session.groupKey
            ?? LSTPopViewSession.GroupKey(scopeID: popup.creationContext.scopeID, groupID: popup.groupId)
        return sessions.filter { $0.groupKey == key }.map(\.popup)
    }

    /// 快照在 pop 调用当下生成；等待回调期间修改配置，只影响下一轮重新 pop。
    func enqueue(_ popup: LSTPopView, style: LSTPopStyle, duration: TimeInterval) {
        guard acceptsEnqueue(popup.creationContext), popup.canEnqueue,
              !sessions.contains(where: { $0.popup === popup }),
              !pendingEnqueues.contains(where: { $0.session.popup === popup }) else { return }
        pendingEnqueues.append(Intent(session: LSTPopViewSession(popup: popup), style: style, duration: duration))
        drainIfPossible()
    }
    private func acceptsEnqueue(_ context: LSTPopViewCreationContext) -> Bool {
        enqueueBarrierDepth == 0 && isValid(context)
    }
    private func transaction(_ body: () -> Void) {
        if transactionDepth == 0 {
            transactionCreationEpoch = creationEpoch
            transactionSceneEpochs = sceneEpochs
        }
        transactionDepth += 1
        body()
        transactionDepth -= 1
        if transactionDepth == 0 {
            transactionCreationEpoch = nil
            transactionSceneEpochs = nil
        }
        drainIfPossible()
    }
    /// 恢复也处于事务中。恢复窗口的 willPop 即使重新弹旧对象，也只入队，不递归打乱生命周期。
    private func drainIfPossible() {
        guard transactionDepth == 0, !isDraining else { return }
        isDraining = true
        defer { isDraining = false; updateDebugInfo() }
        while !pendingEnqueues.isEmpty || !groupsNeedingResume.isEmpty {
            if !pendingEnqueues.isEmpty {
                let intent = pendingEnqueues.removeFirst()
                transaction { self.enqueueNow(intent) }
            } else {
                let keys = groupsNeedingResume
                groupsNeedingResume.removeAll()
                transaction { keys.forEach { self.resumeIfNeeded(group: $0) } }
            }
        }
    }
    private func enqueueNow(_ intent: Intent) {
        let entry = intent.session
        let popup = entry.popup
        guard acceptsEnqueue(entry.context), popup.canEnqueue,
              !sessions.contains(where: { $0.popup === popup }) else { return }
        if let sceneID = entry.sceneID { knownHostScenes[entry.context.scopeID] = sceneID }
        let old = sessions.filter { $0.groupKey == entry.groupKey }
        // 准备中也可被旧窗口的关闭回调撤销；这一步不建立视图层级。
        popup.prepareQueuedPresentation(style: intent.style, duration: intent.duration)
        // 先登记准备中的 Session。若旧窗口回调触发账户清场，当前新窗也必须在屏障内关闭，
        // 不能等 epoch 已推进后才补发它的旧 didDismiss 并让回调创建新账户上下文逃出清场。
        sessions.append(entry)
        if entry.mode == .single {
            old.forEach { $0.popup.forceRemoveForInvalidation() }
        }
        guard sessions.contains(where: { $0 === entry }), acceptsEnqueue(entry.context), popup.canResumeFromQueue else {
            popup.forceRemoveForInvalidation()
            return
        }
        if entry.mode == .queued,
           let current = sessions.last(where: { $0 !== entry && $0.groupKey == entry.groupKey && ($0.popup.isActuallyPresented || $0.popup.superview != nil) }) {
            // 正在 dismiss 的窗仍占据视图树；等待其 didRemove 完整收尾，再选择下一窗。
            // 不能调用 suspend 来打断一个不再处于 presented 的会话并提前穿插新 willPop。
            guard current.popup.isActuallyPresented else { return }
            if entry.priority < current.priority { return }
            current.popup.suspendForQueue()
        }
        // 挂起/endEditing 也能同步触发通知清场，显示前再确认本次登记没有被撤销。
        guard sessions.contains(where: { $0 === entry }), acceptsEnqueue(entry.context), popup.canResumeFromQueue else { return }
        show(entry, resuming: false)
    }
    private func show(_ entry: LSTPopViewSession, resuming: Bool) {
        guard isValid(entry.context), sessions.contains(where: { $0 === entry }) else { return }
        showHistory.removeAll { $0.value == nil || $0.value === entry.popup }
        showHistory.append(WeakPopup(entry.popup))
        entry.popup.performQueuedPresentation(resuming: resuming)
    }

    /// 真实移除的统一事务：先解除登记，再完整通知旧 didDismiss，最后才允许新显示。
    /// 恢复看整个组的可见状态，不再因离开者曾经 single/stack 而遗留悬空等待者。
    func didRemove(_ popup: LSTPopView, notify: () -> Void) {
        transaction {
            let removed = self.sessions.first { $0.popup === popup }
            self.sessions.removeAll { $0.popup === popup }
            self.showHistory.removeAll { $0.value == nil || $0.value === popup }
            if let removed = removed { self.groupsNeedingResume.insert(removed.groupKey) }
            notify()
        }
    }
    private func resumeIfNeeded(group: LSTPopViewSession.GroupKey) {
        guard enqueueBarrierDepth == 0 else { return }
        let candidates = sessions.filter { $0.groupKey == group && isValid($0.context) }
        guard !candidates.contains(where: { $0.popup.isActuallyPresented || $0.popup.superview != nil }) else { return }
        let next = candidates.enumerated().filter { $0.element.popup.canResumeFromQueue }
            .max { lhs, rhs in lhs.element.priority == rhs.element.priority ? lhs.offset < rhs.offset : lhs.element.priority < rhs.element.priority }?.element
        if let next = next { show(next, resuming: next.popup.hasPoppedBefore) }
    }
    /// 等待消费的 pop 意图也可取消，不能因为其尚未登记就稍后复活。
    func cancelPending(_ popup: LSTPopView) {
        pendingEnqueues.removeAll { $0.session.popup === popup }
    }

    // MARK: 普通全移除、账户失效和 scene 销毁

    /// 普通清空只拒绝本次关闭回调入场，结束后旧对象仍可由业务明确重新 pop。
    func removeAll() {
        transaction {
            self.enqueueBarrierDepth += 1
            defer { self.enqueueBarrierDepth -= 1 }
            self.pendingEnqueues.removeAll()
            let snapshot = self.sessions
            snapshot.forEach { $0.popup.forceRemoveForInvalidation() }
            self.groupsNeedingResume.removeAll()
        }
    }
    /// 退出账号/切换根视图前调用。最后推进 epoch，让清场回调里创建的对象也永久失效。
    func invalidateAllScopes() {
        guard !invalidatingAllScopes else { return }
        transaction {
            self.invalidatingAllScopes = true
            self.enqueueBarrierDepth += 1
            defer {
                self.creationEpoch &+= 1
                self.enqueueBarrierDepth -= 1
                self.invalidatingAllScopes = false
            }
            self.pendingEnqueues.removeAll()
            let snapshot = self.sessions
            snapshot.forEach { $0.popup.forceRemoveForInvalidation() }
            self.groupsNeedingResume.removeAll()
        }
    }
    /// scene 失效只触及该 scene。回调中给该 scene 新建的 context 同样留在旧 sceneEpoch。
    func invalidateScopes(in scene: UIScene) {
        let id = ObjectIdentifier(scene)
        guard !invalidatingScenes.contains(id) else { return }
        transaction {
            self.invalidatingScenes.insert(id)
            let affected = self.sessions.filter { $0.sceneID == id || $0.context.sceneID == id }
            let pending = self.pendingEnqueues.filter { $0.session.sceneID == id || $0.session.context.sceneID == id }
            var affectedScopes = Set(affected.map { $0.context.scopeID } + pending.map { $0.session.context.scopeID })
            // 还未 pop 的旧对象也要失效；父视图此时已挂到 scene 可从真实树补认，而非 fallback。
            for (scopeID, scope) in self.hostScopes {
                let actual = (scope.parentView as? UIWindow)?.windowScene ?? scope.parentView?.window?.windowScene
                if scope.sceneID == id || self.knownHostScenes[scopeID] == id || actual.map(ObjectIdentifier.init) == id {
                    affectedScopes.insert(scopeID)
                }
            }
            for scopeID in affectedScopes {
                self.hostInvalidationDepth[scopeID, default: 0] += 1
                self.knownHostScenes[scopeID] = id
                self.hostScopes[scopeID]?.retired = true
            }
            affected.forEach { $0.context.scope.retired = true }
            pending.forEach { $0.session.context.scope.retired = true }
            defer {
                // 回调中 capture 可生成新的 scope record；末尾再次退休，不能因 detached 变 nil 而逃逸。
                for scopeID in affectedScopes {
                    self.hostScopes[scopeID]?.retired = true
                    self.hostInvalidationDepth[scopeID, default: 0] -= 1
                    if self.hostInvalidationDepth[scopeID] == 0 { self.hostInvalidationDepth.removeValue(forKey: scopeID) }
                }
                self.sceneEpochs[id, default: 0] &+= 1
                self.invalidatingScenes.remove(id)
            }
            self.pendingEnqueues.removeAll { affectedScopes.contains($0.session.context.scopeID) }
            affected.forEach { $0.popup.forceRemoveForInvalidation() }
            self.groupsNeedingResume = self.groupsNeedingResume.filter { !affectedScopes.contains($0.scopeID) }
        }
    }
    func removeLast() {
        showHistory.removeAll { item in item.value == nil || !sessions.contains(where: { $0.popup === item.value }) }
        showHistory.last?.value?.dismiss(with: .no, duration: 0)
    }

    /// 无障碍焦点属于最近仍显示的模态窗口。旧窗口的异步恢复不能把焦点抢回新模态后方。
    /// 子窗口关闭后恢复父窗时，原焦点确在父窗内部则允许恢复；跨 window 新模态保守阻止。
    /// isHideBg 是可穿透的非模态展示，不夺取这项所有权。此方法只读，不修改历史或 UIKit 焦点。
    func allowsAccessibilityFocusRestoration(to element: AnyObject) -> Bool {
        let modal = showHistory.reversed().compactMap(\.value).first {
            $0.isActuallyPresented && !$0.isHidden && !$0.isHideBg && isValid($0.creationContext)
        }
        guard let modal = modal else { return true }
        var candidate: AnyObject? = element
        var visited = Set<ObjectIdentifier>()
        // UIAccessibilityElement 的 container 可以继续是另一个 accessibility element，
        // 也可能错误地形成环；身份集合和固定上限同时保证主线程不会被外部容器链拖住。
        for _ in 0..<16 {
            guard let current = candidate, visited.insert(ObjectIdentifier(current)).inserted else { return false }
            if let view = current as? UIView { return view === modal || view.isDescendant(of: modal) }
            guard let accessibilityElement = current as? UIAccessibilityElement else { return false }
            candidate = accessibilityElement.accessibilityContainer as AnyObject?
        }
        return false
    }

    /// 调试只显示数量，标签不接收触摸/辅助功能焦点，不打印弹窗内容或用户输入。
    private func updateDebugInfo() {
        let text = "LSTPopView S:\(sessions.count)"
        if logStyle == .console || logStyle == .all { print(text) }
        guard logStyle == .window || logStyle == .all else { debugLabel?.removeFromSuperview(); debugLabel = nil; return }
        guard let window = lstPopKeyWindow() else { return }
        let label = debugLabel ?? UILabel(frame: CGRect(x: 4, y: window.safeAreaInsets.top, width: 150, height: 24))
        label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        label.isUserInteractionEnabled = false
        label.isAccessibilityElement = false
        label.text = text
        window.addSubview(label)
        debugLabel = label
    }
}
