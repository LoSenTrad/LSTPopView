import UIKit
import LSTPopViewSwift

/// Both implementations are instantiated in this consumer executable.
/// The XCTest bundle calls this app-owned helper rather than linking a second
/// copy of the Swift package into the test bundle.
@MainActor
final class CoexistencePair {
    let host: UIView
    let legacy: LegacyPopupAdapter
    let native: LSTPopViewSwift.LSTPopView
    private(set) var nativeDidPopCount = 0
    private(set) var nativeDidDismissCount = 0

    init(host: UIView) {
        self.host = host
        legacy = LegacyPopupAdapter(host: host)

        let content = UILabel(frame: CGRect(x: 0, y: 0, width: 260, height: 110))
        content.text = "Swift · LSTPopViewSwift.LSTPopView"
        content.textAlignment = .center
        content.numberOfLines = 0
        content.backgroundColor = .systemMint
        content.layer.cornerRadius = 16
        content.clipsToBounds = true

        guard let popup = LSTPopViewSwift.LSTPopView.initWithCustomView(
            content, parentView: host, popStyle: .no, dismissStyle: .no
        ) else {
            preconditionFailure("Swift factory must instantiate a popup")
        }
        native = popup
        native.identifier = "coexistence.swift"
        native.adjustY = 75
        native.isClickBgDismiss = true
        native.popViewDidPopBlock = { [weak self] in
            self?.nativeDidPopCount += 1
        }
        native.popViewDidDismissBlock = { [weak self] in
            self?.nativeDidDismissCount += 1
        }
    }

    var legacyRuntimeName: String { legacy.runtimeClassName }
    var nativeRuntimeName: String { NSStringFromClass(type(of: native)) }
    var isLegacyVisible: Bool { legacy.popupView?.superview === host }
    var isNativeVisible: Bool { native.superview === host }
    var legacyCount: Int { Int(LegacyPopupAdapter.registeredPopupCount()) }
    var nativeCount: Int { LSTPopViewSwift.LSTPopView.getAllPopView().count }

    func showBoth() {
        legacy.pop()
        native.pop()
    }

    func clearNativeOnly() { LSTPopViewSwift.LSTPopView.removeAllPopView() }
    func clearLegacyOnly() { LegacyPopupAdapter.removeAllLegacyPopups() }

    /// The OC no-animation implementation still delivers dismissal via a
    /// dispatch_after(0) callback. Tests await that real lifecycle callback.
    func dismissBoth() {
        native.dismiss()
        legacy.dismiss()
    }
}
