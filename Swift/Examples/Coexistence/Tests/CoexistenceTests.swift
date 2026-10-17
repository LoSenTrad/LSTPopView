import XCTest
import UIKit
@testable import CoexistenceApp

/// Hosted tests execute in the exact app that links both production libraries.
/// Neither the OC popup nor LSTTimer is replaced by a stub in this fixture.
final class CoexistenceTests: XCTestCase {
    @MainActor
    private func waitFor(_ expectations: [XCTestExpectation]) async {
        // Both XCTestExpectation and XCTWaiter are Sendable. A static waiter
        // avoids sending a main-actor XCTestCase instance to a nonisolated
        // async XCTestCase.fulfillment method under Swift 6 strict checking.
        let result = await XCTWaiter.fulfillment(of: expectations, timeout: 3)
        XCTAssertEqual(result, .completed)
    }

    @MainActor
    private func makePair() -> CoexistencePair {
        CoexistencePair(host: UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 844)))
    }

    @MainActor
    func testRuntimeNamesAndRealTimerAreDistinctAndLoaded() throws {
        let pair = makePair()
        let legacyView = try XCTUnwrap(pair.legacy.popupView)
        XCTAssertEqual(pair.legacyRuntimeName, "LSTPopView")
        XCTAssertNotEqual(pair.nativeRuntimeName, pair.legacyRuntimeName)
        XCTAssertTrue(pair.nativeRuntimeName.contains("LSTPopViewSwift"))
        XCTAssertTrue(NSClassFromString("LSTPopView") === type(of: legacyView))
        XCTAssertTrue(NSClassFromString(pair.nativeRuntimeName) === type(of: pair.native))
        XCTAssertTrue(LegacyPopupAdapter.isRealTimerClassLoaded())
    }

    @MainActor
    func testNativeCanPopAndDismissWithLifecycleCallbacks() {
        let pair = makePair()
        pair.native.pop()
        XCTAssertTrue(pair.isNativeVisible)
        XCTAssertEqual(pair.nativeDidPopCount, 1)
        pair.native.dismiss()
        XCTAssertFalse(pair.isNativeVisible)
        XCTAssertEqual(pair.nativeDidDismissCount, 1)
        XCTAssertEqual(pair.nativeCount, 0)
    }

    @MainActor
    func testOriginalOCCanPopAndDismissWithLifecycleCallbacks() async {
        let pair = makePair()
        let popped = expectation(description: "Original OC didPop")
        let dismissed = expectation(description: "Original OC didDismiss")
        pair.legacy.onDidPop = { popped.fulfill() }
        pair.legacy.onDidDismiss = { dismissed.fulfill() }
        pair.legacy.pop()
        XCTAssertTrue(pair.isLegacyVisible)
        await waitFor([popped])
        pair.legacy.dismiss()
        await waitFor([dismissed])
        XCTAssertFalse(pair.isLegacyVisible)
        XCTAssertNil(pair.legacy.popupView, "Original OC didDismiss means deallocation, not only removal")
        XCTAssertEqual(pair.legacy.didPopCount, 1)
        XCTAssertEqual(pair.legacy.didDismissCount, 1)
        XCTAssertEqual(pair.legacyCount, 0)
    }

    @MainActor
    func testOriginalOCCanCreateFreshInstanceAfterDismissal() async {
        let pair = makePair()
        for round in 1...2 {
            let popped = expectation(description: "Original OC pop round \(round)")
            let dismissed = expectation(description: "Original OC dealloc round \(round)")
            pair.legacy.onDidPop = { popped.fulfill() }
            pair.legacy.onDidDismiss = { dismissed.fulfill() }
            pair.legacy.pop()
            await waitFor([popped])
            XCTAssertTrue(pair.isLegacyVisible)
            pair.legacy.dismiss()
            await waitFor([dismissed])
            XCTAssertNil(pair.legacy.popupView)
            XCTAssertEqual(pair.legacy.didPopCount, UInt(round))
            XCTAssertEqual(pair.legacy.didDismissCount, UInt(round))
        }
    }

    @MainActor
    func testBothCanBePresentedAndDismissedInTheSameApp() async {
        let pair = makePair()
        let popped = expectation(description: "OC appeared beside Swift")
        let dismissed = expectation(description: "OC dismissed beside Swift")
        pair.legacy.onDidPop = { popped.fulfill() }
        pair.legacy.onDidDismiss = { dismissed.fulfill() }
        pair.showBoth()
        await waitFor([popped])
        XCTAssertTrue(pair.isLegacyVisible)
        XCTAssertTrue(pair.isNativeVisible)
        XCTAssertEqual(pair.legacyCount, 1)
        XCTAssertEqual(pair.nativeCount, 1)
        pair.dismissBoth()
        await waitFor([dismissed])
        XCTAssertFalse(pair.isLegacyVisible)
        XCTAssertFalse(pair.isNativeVisible)
        XCTAssertEqual(pair.legacyCount, 0)
        XCTAssertEqual(pair.nativeCount, 0)
    }

    @MainActor
    func testClearingSwiftDoesNotRemoveOriginalOC() async {
        let pair = makePair()
        let popped = expectation(description: "OC appeared")
        let dismissed = expectation(description: "OC final cleanup")
        pair.legacy.onDidPop = { popped.fulfill() }
        pair.legacy.onDidDismiss = { dismissed.fulfill() }
        pair.showBoth()
        await waitFor([popped])
        pair.clearNativeOnly()
        XCTAssertFalse(pair.isNativeVisible)
        XCTAssertTrue(pair.isLegacyVisible)
        XCTAssertEqual(pair.legacyCount, 1)
        pair.legacy.dismiss()
        await waitFor([dismissed])
    }

    @MainActor
    func testClearingOCDoesNotRemoveNativeSwift() async {
        let pair = makePair()
        let popped = expectation(description: "OC appeared")
        let dismissed = expectation(description: "OC cleared independently")
        pair.legacy.onDidPop = { popped.fulfill() }
        pair.legacy.onDidDismiss = { dismissed.fulfill() }
        pair.showBoth()
        await waitFor([popped])
        pair.clearLegacyOnly()
        await waitFor([dismissed])
        XCTAssertFalse(pair.isLegacyVisible)
        XCTAssertTrue(pair.isNativeVisible)
        XCTAssertEqual(pair.nativeCount, 1)
        pair.native.dismiss()
        XCTAssertEqual(pair.nativeCount, 0)
    }
}
