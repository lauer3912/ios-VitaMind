import Foundation
import SwiftUI
import UserNotifications
import UIKit

// MARK: - NotificationManager
//
// Centralised wrapper around `UNUserNotificationCenter` for VitaPocket.
// Handles: permission request, scheduling three categories of local
// notifications (daily card pull, habit reminder, streak rescue),
// and a user-facing on/off toggle persisted in UserDefaults.
//
// Note: This is a *local* notification implementation. It does not
// require `aps-environment` entitlements or any server. Each
// notification is scheduled client-side via
// `UNCalendarNotificationTrigger` and survives app restarts.
@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    // MARK: - Published State

    /// Mirrors `UNAuthorizationStatus` so SwiftUI can react.
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    /// User-controlled master switch, persisted in UserDefaults.
    @AppStorage("vita_notifications_enabled") var isEnabled: Bool = true

    // MARK: - Notification Identifiers (stable, used for re-scheduling)

    private enum ID {
        static let dailyPull         = "vita.notify.daily_pull"
        static let dailyHabit        = "vita.notify.daily_habit"
        static let streakRescue      = "vita.notify.streak_rescue"
    }

    // MARK: - Init

    private init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        Task { await refreshAuthorizationStatus() }
    }

    // MARK: - Public API

    /// Request notification permission. Safe to call multiple times.
    /// Returns the final authorization status.
    @discardableResult
    func requestAuthorization() async -> UNAuthorizationStatus {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print("[NotificationManager] requestAuthorization granted=\(granted)")
        } catch {
            print("[NotificationManager] requestAuthorization error: \(error)")
        }
        await refreshAuthorizationStatus()
        return authorizationStatus
    }

    /// Re-schedule every notification the app currently needs.
    /// Called on app launch and whenever the user toggles `isEnabled`.
    func rescheduleAll(habitCount: Int) async {
        cancelAll()
        guard isEnabled, authorizationStatus == .authorized else {
            print("[NotificationManager] rescheduleAll skipped (enabled=\(isEnabled), status=\(authorizationStatus.rawValue))")
            return
        }
        scheduleDailyCardPullReminder()    // 每天 09:00
        scheduleDailyHabitReminder()       // 每天 20:00
        if habitCount > 0 {
            scheduleStreakRescueReminder() // 每天 22:00
        }
        print("[NotificationManager] rescheduleAll done (habitCount=\(habitCount))")
    }

    /// Cancel every notification the app owns.
    func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: [ID.dailyPull, ID.dailyHabit, ID.streakRescue]
        )
    }

    // MARK: - Status

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Individual Schedulers

    /// Fire a one-shot test notification 1 second from now. Useful for
    /// verifying permission is granted and the banner displays correctly
    /// without waiting for the next 9 AM / 8 PM / 10 PM trigger.
    func sendTestNotification() async {
        let status = await refreshAuthorizationStatusRetval()
        guard status == .authorized else {
            print("[NotificationManager] sendTestNotification skipped (status=\(status.rawValue))")
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "🧪 Test notification"
        content.body  = "If you can see this, VitaPocket can reach you. ✅"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "vita.notify.test", content: content, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("[NotificationManager] test notification scheduled")
        } catch {
            print("[NotificationManager] test notification error: \(error)")
        }
    }

    private func refreshAuthorizationStatusRetval() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        return settings.authorizationStatus
    }

    /// "Your daily card is ready" — every day at 09:00 local time.
    private func scheduleDailyCardPullReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🎴 Today's card is ready"
        content.body  = "Tap to pull your daily health card and earn XP."
        content.sound = .default
        content.userInfo = ["category": "daily_pull", "deepLink": "vitapocket://pull"]

        let trigger = calendarTrigger(hour: 9, minute: 0)
        let request = UNNotificationRequest(identifier: ID.dailyPull, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[NotificationManager] dailyPull error: \(error)") }
        }
    }

    /// "Don't break your streak" — every day at 20:00 local time.
    private func scheduleDailyHabitReminder() {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Habit check-in"
        content.body  = "A few habits are still on your list — keep your streak alive."
        content.sound = .default
        content.userInfo = ["category": "daily_habit", "deepLink": "vitapocket://habits"]

        let trigger = calendarTrigger(hour: 20, minute: 0)
        let request = UNNotificationRequest(identifier: ID.dailyHabit, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[NotificationManager] dailyHabit error: \(error)") }
        }
    }

    /// "Rescue your streak" — every day at 22:00, a final nudge.
    private func scheduleStreakRescueReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Last call"
        content.body  = "Day's almost over. One habit can save your streak."
        content.sound = .default
        content.userInfo = ["category": "streak_rescue", "deepLink": "vitapocket://habits"]

        let trigger = calendarTrigger(hour: 22, minute: 0)
        let request = UNNotificationRequest(identifier: ID.streakRescue, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[NotificationManager] streakRescue error: \(error)") }
        }
    }

    // MARK: - Helpers

    /// Build a repeating daily `UNCalendarNotificationTrigger` at the given local hour/minute.
    private func calendarTrigger(hour: Int, minute: Int) -> UNCalendarNotificationTrigger {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }
}

// MARK: - NotificationDelegate
//
// Ensures banner + sound play even when the app is in the foreground.
// Without this, iOS suppresses banners while the user is actively using
// the app, which makes local notifications feel broken during testing.
private final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }
}
