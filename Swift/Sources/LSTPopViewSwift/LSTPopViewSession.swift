// LSTPopView 的会话值：把“可继续编辑的配置”与“已登记的一轮弹窗”明确分开。
// UIKit 父容器仅弱引用；scope UUID 保持稳定，容器释放后不会改成另一个 fallback 身份。
import UIKit

/// 一个父 UIView 对应一个稳定宿主作用域。对象本身由 context/manager 持有，父视图不被延寿。
/// 宿主释放或 scene/账户失效时标记 retired，所有已经捕获该作用域的对象立即变成无效。
@MainActor
final class LSTPopViewHostScope {
    let id: UUID
    weak var parentView: UIView?
    let sceneID: ObjectIdentifier?
    var retired = false

    init(id: UUID, parentView: UIView, sceneID: ObjectIdentifier?) {
        self.id = id
        self.parentView = parentView
        self.sceneID = sceneID
    }
}

/// 工厂创建时捕获，随后不可更换。清场末尾推进 epoch，既拒绝旧对象，也拒绝清场回调中新建对象。
/// 同一个 UIView 在新账户下仍可以创建新 context；旧 context 的 epoch 不会因此被“刷新”。
@MainActor
final class LSTPopViewCreationContext {
    let scope: LSTPopViewHostScope
    let creationEpoch: UInt64
    let sceneEpoch: UInt64
    var scopeID: UUID { scope.id }
    var parentView: UIView? { scope.parentView }
    var sceneID: ObjectIdentifier? { scope.sceneID }

    init(scope: LSTPopViewHostScope, creationEpoch: UInt64, sceneEpoch: UInt64) {
        self.scope = scope
        self.creationEpoch = creationEpoch
        self.sceneEpoch = sceneEpoch
    }
}

/// 一轮登记后不再读取 popup.groupId/priority/isStack/isSingle。
/// 业务仍可修改这些公开配置，但只在该对象下次 dismiss 后重新 pop 时采纳。
@MainActor
final class LSTPopViewSession {
    enum Mode { case queued, stack, single }
    struct GroupKey: Hashable {
        let scopeID: UUID
        let groupID: String?
    }

    /// Session 是管理器对弹窗的唯一强所有权，待显示窗口也必须存活直到出队或失效清理。
    let popup: LSTPopView
    let context: LSTPopViewCreationContext
    /// 工厂可能在父视图尚未挂载时创建；入队时再补一次实际 scene 快照，不迁移已登记会话。
    let sceneID: ObjectIdentifier?
    let groupKey: GroupKey
    let priority: CGFloat
    let mode: Mode

    init(popup: LSTPopView) {
        self.popup = popup
        context = popup.creationContext
        let actualScene = (context.parentView as? UIWindow)?.windowScene ?? context.parentView?.window?.windowScene
        sceneID = context.sceneID ?? actualScene.map(ObjectIdentifier.init)
        groupKey = GroupKey(scopeID: context.scopeID, groupID: popup.groupId)
        // 即使客户端给出 NaN/无穷，排序仍需是确定全序，不能污染优先级队列。
        priority = popup.priority.isFinite ? min(1000, max(0, popup.priority)) : 0
        mode = popup.isSingle ? .single : (popup.isStack ? .stack : .queued)
    }
}
