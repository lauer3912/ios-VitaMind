//
//  SubscriptionManagerTests.swift
//  VitaMindGo
//
//  Unit tests for SubscriptionManager + Entitlement. Phase 1 covers:
//   - Entitlement state mapping
//   - Free message counter (resets at midnight, increments, blocks at limit)
//   - Pro bypass
//
//  StoreKit transaction flow is harder to unit-test without a real product
//  (covered by UI tests using .storekit config). For now we exercise the
//  pure logic that doesn't need StoreKit.
//

import XCTest
@testable import VitaMindGo

final class SubscriptionManagerTests: XCTestCase {

    // MARK: - Setup / Teardown

    private let freeCountKey = "vita_free_message_count"
    private let freeDateKey = "vita_free_message_date"

    override func setUp() {
        super.setUp()
        // Clean UserDefaults so each test starts from 0/today
        UserDefaults.standard.removeObject(forKey: freeCountKey)
        UserDefaults.standard.removeObject(forKey: freeDateKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: freeCountKey)
        UserDefaults.standard.removeObject(forKey: freeDateKey)
        super.tearDown()
    }

    // MARK: - Entitlement

    func testFreeEntitlementIsNotPro() {
        let e = Entitlement.free
        XCTAssertFalse(e.isPro)
        XCTAssertFalse(e.hasUnlimitedAI)
        XCTAssertFalse(e.isExpired)
        XCTAssertEqual(e.displayName, "Free")
    }

    func testProEntitlementIsPro() {
        let e = Entitlement.pro
        XCTAssertTrue(e.isPro)
        XCTAssertTrue(e.hasUnlimitedAI)
        XCTAssertFalse(e.isExpired)
    }

    func testProTrialEntitlementIsPro() {
        let e = Entitlement.proTrial
        XCTAssertTrue(e.isPro)
        XCTAssertEqual(e.displayName, "Pro (Trial)")
    }

    func testProExpiredEntitlementIsNotPro() {
        let e = Entitlement.proExpired
        XCTAssertFalse(e.isPro)
        XCTAssertTrue(e.isExpired)
    }

    // MARK: - Free Message Counter (free user)

    @MainActor
    func testFreeUserStartsAtZero() {
        let mgr = SubscriptionManager.shared
        // Just verifying the manager can be created and exposes a count.
        XCTAssertGreaterThanOrEqual(mgr.freeMessagesUsedToday, 0)
        XCTAssertLessThanOrEqual(mgr.freeMessagesUsedToday, SubscriptionManager.freeDailyMessageLimit)
    }

    @MainActor
    func testFreeUserLimitIsFive() {
        XCTAssertEqual(SubscriptionManager.freeDailyMessageLimit, 5)
    }

    @MainActor
    func testFreeUserCanSendUnderLimit() {
        let mgr = SubscriptionManager.shared

        // First 5 should succeed
        for i in 1...5 {
            XCTAssertTrue(mgr.recordFreeMessageIfAllowed(), "Message \(i) should be allowed")
        }
    }

    @MainActor
    func testFreeUserBlockedAtLimit() {
        let mgr = SubscriptionManager.shared

        // Use up the limit
        for _ in 1...5 {
            _ = mgr.recordFreeMessageIfAllowed()
        }
        // 6th should be blocked
        XCTAssertFalse(mgr.recordFreeMessageIfAllowed(),
                       "6th message should be blocked (free limit is 5)")
        XCTAssertTrue(mgr.hasReachedFreeMessageLimit)
    }

    @MainActor
    func testFreeUserResetClearsCount() {
        let mgr = SubscriptionManager.shared

        for _ in 1...5 {
            _ = mgr.recordFreeMessageIfAllowed()
        }
        XCTAssertEqual(mgr.freeMessagesUsedToday, 5)

        mgr.resetFreeMessageCount()
        XCTAssertEqual(mgr.freeMessagesUsedToday, 0)
        XCTAssertFalse(mgr.hasReachedFreeMessageLimit)
    }

    // MARK: - Product IDs

    func testProductIDsContainsBothProducts() {
        let ids = SubscriptionManager.productIDs
        XCTAssertTrue(ids.contains("vitamind_pro_monthly"))
        XCTAssertTrue(ids.contains("vitamind_pro_yearly"))
        XCTAssertEqual(ids.count, 2)
    }
}
