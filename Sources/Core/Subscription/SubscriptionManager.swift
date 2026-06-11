//
//  SubscriptionManager.swift
//  VitaMindGo
//
//  StoreKit 2 wrapper. Owns the user's Pro entitlement and the free-tier
//  daily message counter.
//
//  Phase 1 (v3.1.0) — client-side only:
//    - Product loading via Product.products(for:)
//    - Purchase via Product.purchase()
//    - JWS verification via .verified(unverified) (built-in)
//    - Transaction.updates listener for live entitlement changes
//    - Restore purchases via Transaction.currentEntitlements
//    - No backend (App Store Server Notifications V2 deferred to v3.2.0)
//
//  Required App Store Connect configuration (see docs/v3.1.0-IAP-Plan.md §4):
//    - Subscription Group: "VitaMindGo Pro"
//    - Product: "vitamind_pro_monthly"  ($4.99 / month, 7-day trial)
//    - Product: "vitamind_pro_yearly"   ($39.99 / year, no trial)
//
//  Privacy: subscription state stays on device. We never phone home with
//  user identity — Pro is recovered via Apple ID, no account required.
//

import Foundation
import StoreKit
import Combine
import os.log

@MainActor
final class SubscriptionManager: ObservableObject {

    // MARK: - Public State

    /// Current Pro entitlement (free / pro / proTrial / proExpired).
    @Published private(set) var entitlement: Entitlement = .free

    /// Available products loaded from App Store. Empty until first `loadProducts()` call.
    @Published private(set) var products: [Product] = []

    /// True while a purchase is in flight (used to disable buttons).
    @Published private(set) var isPurchasing: Bool = false

    /// Last purchase error, if any. Cleared on next successful action.
    @Published private(set) var lastError: String?

    // MARK: - Configuration

    /// App Store Connect product IDs. Must match the ASC backend exactly.
    static let productIDs: Set<String> = [
        "vitamind_pro_monthly",
        "vitamind_pro_yearly"
    ]

    /// Free-tier daily AI message cap. Resets at local midnight.
    static let freeDailyMessageLimit: Int = 5

    // MARK: - UserDefaults Keys

    private enum DefaultsKey {
        static let freeMessageCount = "vita_free_message_count"
        static let freeMessageDate  = "vita_free_message_date"  // yyyy-MM-dd (local)
    }

    // MARK: - Singleton

    static let shared = SubscriptionManager()
    private init() {
        // Refresh free counter on init (in case app was killed and re-launched next day).
        refreshFreeMessageCountIfNewDay()
        // Kick off product loading + transaction listener
        Task { await self.loadProducts() }
        Task { await self.listenForTransactionUpdates() }
        Task { await self.refreshEntitlement() }
    }

    private let log = Logger(subsystem: "com.ggsheng.VitaMind", category: "Subscription")

    // MARK: - Public API

    /// Load the product list from the App Store. Safe to call multiple times.
    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: Self.productIDs)
            // Sort: Monthly first, then Yearly (helps UI consistency)
            self.products = loaded.sorted { lhs, rhs in
                if lhs.id.contains("monthly") { return true }
                if rhs.id.contains("monthly") { return false }
                return lhs.price < rhs.price
            }
            log.info("Loaded \(self.products.count) products: \(self.products.map(\.id))")
        } catch {
            log.error("Failed to load products: \(error.localizedDescription)")
            self.lastError = "Could not load subscription options. Please try again."
        }
    }

    /// Buy a product. Returns true if the purchase was successful.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        guard !isPurchasing else { return false }
        isPurchasing = true
        defer { isPurchasing = false }
        lastError = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    log.info("Purchase verified: \(transaction.productID)")
                    await transaction.finish()
                    await refreshEntitlement()
                    return true

                case .unverified(_, let error):
                    log.error("Purchase unverified: \(error.localizedDescription)")
                    lastError = "Purchase could not be verified. Please contact support if you were charged."
                    return false
                }

            case .userCancelled:
                log.info("User cancelled purchase")
                return false

            case .pending:
                log.info("Purchase pending (e.g. Ask to Buy)")
                lastError = "Purchase is pending approval. We'll unlock Pro once it completes."
                return false

            @unknown default:
                log.error("Unknown purchase result")
                lastError = "An unexpected error occurred. Please try again."
                return false
            }
        } catch {
            log.error("Purchase failed: \(error.localizedDescription)")
            lastError = error.localizedDescription
            return false
        }
    }

    /// Restore previous purchases. Required by App Store guideline 3.1.5.
    /// (User can restore from another device using same Apple ID.)
    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        lastError = nil

        do {
            try await AppStore.sync()
            log.info("AppStore.sync() completed")
            await refreshEntitlement()
        } catch {
            log.error("Restore failed: \(error.localizedDescription)")
            lastError = "Could not restore purchases. Please try again."
        }
    }

    // MARK: - Entitlement

    /// Re-derive entitlement from current verified transactions.
    func refreshEntitlement() async {
        var foundActive: Entitlement = .free

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                log.warning("Skipping unverified transaction: \(String(describing: result))")
                continue
            }

            // transaction.revocationDate != nil → refunded/revoked
            if transaction.revocationDate != nil {
                log.info("Transaction \(transaction.productID) revoked at \(transaction.revocationDate!)")
                continue
            }

            // Determine kind by product ID
            let isPro = Self.productIDs.contains(transaction.productID)
            guard isPro else {
                log.warning("Unknown product ID in transactions: \(transaction.productID)")
                continue
            }

            // Check if it's a free trial (transaction.offerID populated + type == .introductory)
            if let offer = transaction.offerID,
               offer.contains("intro") || offer.contains("trial") {
                foundActive = .proTrial
            } else {
                foundActive = .pro
            }

            // First active one wins; we don't need to keep iterating for entitlement
            // purposes. But we still call finish() if not finished to clean up.
            await transaction.finish()
            break
        }

        self.entitlement = foundActive
        log.info("Entitlement updated: \(self.entitlement.displayName)")
    }

    /// Background listener for transaction updates (renewals, refunds, family sharing).
    private func listenForTransactionUpdates() async {
        for await result in Transaction.updates {
            log.info("Transaction update received")
            if case .verified(let transaction) = result {
                await transaction.finish()
            }
            await refreshEntitlement()
        }
    }

    // MARK: - Free Tier Daily Counter

    /// Number of AI messages the user has sent today (resets at midnight local time).
    var freeMessagesUsedToday: Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: DefaultsKey.freeMessageCount)
    }

    /// Remaining free messages for today. Returns `Int.max` if user is Pro.
    var freeMessagesRemainingToday: Int {
        if entitlement.isPro { return Int.max }
        return max(0, Self.freeDailyMessageLimit - freeMessagesUsedToday)
    }

    /// True if the free user has hit today's limit.
    var hasReachedFreeMessageLimit: Bool {
        if entitlement.isPro { return false }
        return freeMessagesRemainingToday == 0
    }

    /// Increment the free message counter. Call this BEFORE sending an AI message.
    /// Returns true if the user is allowed to send (under limit or Pro), false if over limit.
    @discardableResult
    func recordFreeMessageIfAllowed() -> Bool {
        refreshFreeMessageCountIfNewDay()

        // Pro users always allowed
        if entitlement.isPro { return true }

        // Free user, check limit
        if hasReachedFreeMessageLimit {
            return false
        }

        // Increment
        let defaults = UserDefaults.standard
        let newCount = defaults.integer(forKey: DefaultsKey.freeMessageCount) + 1
        defaults.set(newCount, forKey: DefaultsKey.freeMessageCount)
        log.debug("Free message count incremented to \(newCount)/\(Self.freeDailyMessageLimit)")
        return true
    }

    /// Reset free counter (used by "Reset" debug action, and called automatically
    /// on day change).
    func resetFreeMessageCount() {
        UserDefaults.standard.set(0, forKey: DefaultsKey.freeMessageCount)
        UserDefaults.standard.set(Self.todayDateString(), forKey: DefaultsKey.freeMessageDate)
    }

    /// If the stored date is not today, reset counter to 0.
    private func refreshFreeMessageCountIfNewDay() {
        let defaults = UserDefaults.standard
        let stored = defaults.string(forKey: DefaultsKey.freeMessageDate) ?? ""
        let today = Self.todayDateString()
        if stored != today {
            defaults.set(0, forKey: DefaultsKey.freeMessageCount)
            defaults.set(today, forKey: DefaultsKey.freeMessageDate)
            log.debug("New day detected, free message counter reset to 0")
        }
    }

    private static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }

    // MARK: - Convenience for UI

    /// Pretty price for paywall, e.g. "$4.99/mo".
    func formattedPrice(for product: Product) -> String {
        let price = product.displayPrice
        if product.id.contains("monthly") {
            return "\(price)/mo"
        } else if product.id.contains("yearly") {
            return "\(price)/yr"
        }
        return price
    }

    /// Lookup the monthly product, if loaded.
    var monthlyProduct: Product? {
        products.first { $0.id == "vitamind_pro_monthly" }
    }

    /// Lookup the yearly product, if loaded.
    var yearlyProduct: Product? {
        products.first { $0.id == "vitamind_pro_yearly" }
    }
}
