//
//  Entitlement.swift
//  VitaMindGo
//
//  Pro entitlement state. Used by UI to gate premium features and by
//  MiniMaxService to enforce free-tier message limits.
//
//  Phase 1 (v3.1.0): client-side only (no backend). Entitlement is derived
//  from StoreKit 2's verified Transaction history.
//

import Foundation

/// Pro entitlement level. Derived from active StoreKit transactions.
enum Entitlement: String, Codable, CaseIterable {
    /// No active subscription. Limited to 5 AI messages per day.
    case free

    /// Active Pro subscription (Monthly or Yearly). Unlimited AI, advanced insights, etc.
    case pro

    /// In 7-day free trial period. Behaves like .pro but UI may show "Trial ends in N days".
    case proTrial

    /// Trial or subscription expired, still within grace period (App Store refund flow).
    /// Treat as .free for now; show "Subscription expired" banner.
    case proExpired

    // MARK: - Convenience

    /// True if the user has full Pro access (active subscription or trial).
    var isPro: Bool {
        switch self {
        case .pro, .proTrial: return true
        case .free, .proExpired: return false
        }
    }

    /// True if we should treat the user as Pro for feature gating purposes.
    /// Same as `isPro` for now; kept as separate property to allow future
    /// grace-period logic without renaming.
    var hasUnlimitedAI: Bool { isPro }

    /// True if we should show a "subscription expired" UI banner.
    var isExpired: Bool { self == .proExpired }

    /// Human-readable label for Settings / debug screens.
    var displayName: String {
        switch self {
        case .free:       return "Free"
        case .pro:        return "Pro"
        case .proTrial:   return "Pro (Trial)"
        case .proExpired: return "Pro (Expired)"
        }
    }
}
