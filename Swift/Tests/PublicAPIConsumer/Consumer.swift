// This fixture is intentionally compiled as an EXTERNAL consumer module.
// Use ordinary `import`, never `@testable import`: every referenced declaration
// must be available to an application that installs LSTPopViewSwift.
//
// The verification script type-checks this file against the emitted library
// module. It does not call the function below or submit any application action.
import UIKit
import LSTPopViewSwift

// Module qualification is also the migration spelling for an application that
// imports both the legacy Objective-C library and this native Swift library.
private typealias NativePopup = LSTPopViewSwift.LSTPopView

/// A consumer can conform without implementing every optional lifecycle hook.
/// This specifically checks that the protocol's default implementations were
/// exported, rather than only visible to the library's @testable unit tests.
@MainActor
private final class DefaultsOnlyDelegate: LSTPopViewProtocol {}

/// A consumer can override just the lifecycle hooks that it needs.
@MainActor
private final class CustomDelegate: LSTPopViewProtocol {
    private(set) var didPresent = false

    func lst_PopViewDidPop(for popView: NativePopup) {
        didPresent = true
    }
}

/// Compile-only API coverage. No app, window, account, or scene is changed unless
/// an application explicitly calls this fixture; the verification never does.
@MainActor
private func consumePublicAPI(parent: UIView, scene: UIScene, coder: NSCoder) -> [NativePopup] {
    let content = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 160))

    // Cover the UIView initializers and all public legacy-compatible factories.
    let direct = NativePopup(frame: .zero)
    let decoded = NativePopup(coder: coder)
    let inferredHost = NativePopup.initWithCustomView(UIView(frame: content.frame))
    let inferredHostWithStyles = NativePopup.initWithCustomView(
        UIView(frame: content.frame), popStyle: .fade, dismissStyle: .scale
    )
    guard let popup = NativePopup.initWithCustomView(
        content, parentView: parent, popStyle: .no, dismissStyle: .no
    ) else {
        return [direct, decoded, inferredHost, inferredHostWithStyles].compactMap { $0 }
    }

    // Every public enum case and compatibility alias remains accessible.
    let popStyles: [LSTPopStyle] = [
        .fade, .no, .scale,
        .smoothFromTop, .smoothFromLeft, .smoothFromBottom, .smoothFromRight,
        .springFromTop, .springFromLeft, .springFromBottom, .springFromRight,
        .cardDropFromLeft, .cardDropFromRight, .NO
    ]
    let dismissStyles: [LSTDismissStyle] = [
        .fade, .no, .scale,
        .smoothToTop, .smoothToLeft, .smoothToBottom, .smoothToRight,
        .cardDropToLeft, .cardDropToRight, .cardDropToTop, .NO
    ]
    let hemStyles: [LSTHemStyle] = [
        .center, .top, .left, .bottom, .right,
        .topLeft, .bottomLeft, .bottomRight, .topRight
    ]
    let activityStyles: [LSTActivityStyle] = [.no, .scale, .shake, .NO]
    let sweepDismissStyles: [LSTSweepDismissStyle] = [.velocity, .smooth]
    let logStyles: [LSTPopViewLogStyle] = [.no, .window, .console, .all, .NO, .ALL]
    _ = LSTPopStyle(rawValue: popStyles[0].rawValue)
    _ = LSTDismissStyle(rawValue: dismissStyles[0].rawValue)
    _ = LSTHemStyle(rawValue: hemStyles[0].rawValue)
    _ = LSTActivityStyle(rawValue: activityStyles[0].rawValue)
    _ = LSTSweepDismissStyle(rawValue: sweepDismissStyles[0].rawValue)
    _ = LSTPopViewLogStyle(rawValue: logStyles[0].rawValue)

    // Both OptionSets expose the initializer/raw value required by OptionSet,
    // their individual directions, combined axes, and old uppercase aliases.
    let dragStyles: [LSTDragStyle] = [
        .no, .NO, .x_Positive, .x_Negative, .y_Positive, .y_Negative,
        .x, .y, .all, .ALL, [.x_Positive, .y_Negative]
    ]
    let sweepStyles: [LSTSweepStyle] = [
        .no, .NO, .x_Positive, .x_Negative, .y_Positive, .y_Negative,
        .x, .y, .all, .ALL, [.x_Negative, .y_Positive]
    ]
    popup.dragStyle = LSTDragStyle(rawValue: dragStyles[0].rawValue)
    popup.sweepStyle = LSTSweepStyle(rawValue: sweepStyles[0].rawValue)

    // Public configuration and read-only properties can be used without exposing
    // the internal manager, creation context, session, clock, or environment.
    popup.identifier = "external-consumer"
    popup.hemStyle = .bottom
    popup.popStyle = .fade
    popup.dismissStyle = .fade
    popup.popDuration = 0.2
    popup.dismissDuration = 0.2
    popup.adjustX = 2
    popup.adjustY = -4
    popup.bgColor = .black
    popup.bgAlpha = 0.25
    popup.isHideBg = false
    popup.isClickBgDismiss = true
    popup.isObserverScreenRotation = true
    popup.isClickFeedback = false
    popup.isAvoidKeyboard = true
    popup.avoidKeyboardSpace = 10
    popup.showTime = 0
    popup.rectCorners = [.topLeft, .topRight]
    popup.cornerRadius = 12
    popup.isImpactFeedback = false
    popup.groupId = "external-consumer"
    popup.isStack = false
    popup.isSingle = false
    popup.priority = 500
    popup.dragDistance = 80
    popup.dragDismissStyle = .smoothToBottom
    popup.dragDismissDuration = 0.2
    popup.dragReboundTime = 0.25
    popup.swipeVelocity = 1_000
    popup.sweepDismissStyle = .velocity
    _ = popup.parentView
    _ = popup.currCustomView
    _ = popup.isPresentationContextValid

    let defaults = DefaultsOnlyDelegate()
    let customized = CustomDelegate()
    popup.delegate = defaults
    popup.delegate = customized
    // Calling a default method from a separate module proves its visibility.
    defaults.lst_PopViewWillPop(for: popup)
    defaults.lst_PopViewDidDismiss(for: popup)
    popup.remove(forDelegate: customized)
    popup.remove(for: defaults)
    popup.removeAllDelegate()

    popup.bgClickBlock = {}
    popup.bgLongPressBlock = {}
    popup.panOffsetBlock = { _ in }
    popup.keyboardWillShowBlock = {}
    popup.keyboardDidShowBlock = {}
    popup.keyboardFrameWillChangeBlock = { _, _, _ in }
    popup.keyboardFrameDidChangeBlock = { _, _, _ in }
    popup.keyboardWillHideBlock = {}
    popup.keyboardDidHideBlock = {}
    popup.popViewWillPopBlock = {}
    popup.popViewDidPopBlock = {}
    popup.popViewWillDismissBlock = {}
    popup.popViewDidDismissBlock = {}
    popup.popViewCountDownBlock = { _, _ in }

    // Public instance overloads and static management are compile checked too.
    popup.pop()
    popup.pop(with: .fade)
    popup.pop(withDuration: 0.2)
    popup.pop(with: .no, duration: 0)
    popup.dismiss()
    popup.dismiss(with: .fade)
    popup.dismiss(withDuration: 0.2)
    popup.dismiss(with: .no, duration: 0)
    _ = NativePopup.getAllPopView()
    _ = NativePopup.getAllPopView(forParentView: parent)
    _ = NativePopup.getAllPopView(for: popup)
    _ = NativePopup.getPopView(forKey: "external-consumer")
    NativePopup.removePopView(popup)
    NativePopup.removePopView(forKey: "external-consumer")
    NativePopup.removeLastPopView()
    NativePopup.removeAllPopView()
    NativePopup.invalidatePopViews(in: scene)
    NativePopup.invalidateAllScopes()
    NativePopup.setLogStyle(.no)

    return [popup, direct, decoded, inferredHost, inferredHostWithStyles].compactMap { $0 }
}
