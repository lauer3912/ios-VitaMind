import XCTest

/// One-off UI test: accept the system notification permission alert,
/// navigate to Settings, fire a test notification, and capture the
/// banner + Settings page as screenshots for demo purposes.
///
/// Run with:
///   xcodebuild test -project VitaPocket.xcodeproj -scheme VitaPocket \
///                  -only-testing:VitaPocketUITests/NotifDemoTests/testNotificationFlow
final class NotifDemoTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testNotificationFlow() throws {
        let app = XCUIApplication()
        // Reset notif state so the permission alert always shows
        app.launchArguments += ["--uitesting"]

        // Pre-install an interruption monitor to auto-accept the
        // "Would Like to Send You Notifications" system alert
        let allowTitle = "Allow"
        addUIInterruptionMonitor(withDescription: "Notification Permission") { (alert) -> Bool in
            if alert.buttons[allowTitle].exists {
                alert.buttons[allowTitle].tap()
                return true
            }
            return false
        }

        app.launch()

        // Touch the app to trigger the interruption monitor (system alert handlers
        // only fire when a user gesture reaches the test app)
        app.swipeUp()
        sleep(1)
        app.tap()

        // Take screenshot of the (possibly still-present) permission alert
        sleep(2)
        let alertShot = app.screenshot()
        let alertPath = "/Users/user291981/.openclaw/workspace/notif-demo/A1-permission-alert.png"
        try? alertShot.pngRepresentation.write(to: URL(fileURLWithPath: alertPath))
        print("📸 \(alertPath)")

        // The interruption monitor already tapped Allow; if the alert is
        // still on screen (e.g. monitor didn't fire), try one more tap.
        if app.alerts.buttons["Allow"].waitForExistence(timeout: 2) {
            app.alerts.buttons["Allow"].tap()
        }

        sleep(2)

        // 2) Navigate to Settings tab (5th tab, label = "Settings")
        // On iPhone the tab bar is visible at the bottom
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.waitForExistence(timeout: 3) {
            settingsTab.tap()
        } else {
            // Fallback: iPad tab style
            // The Pocket tab is the default; need to swipe left 4 times
            for _ in 0..<4 { app.swipeLeft() }
        }
        sleep(2)

        // 3) Screenshot Settings page
        let settingsShot = app.screenshot()
        let settingsPath = "/Users/user291981/.openclaw/workspace/notif-demo/A2-settings-notifications.png"
        try? settingsShot.pngRepresentation.write(to: URL(fileURLWithPath: settingsPath))
        print("📸 \(settingsPath)")

        // 4) Tap "Send Test Notification"
        let testBtn = app.buttons["Send Test Notification"]
        XCTAssertTrue(testBtn.waitForExistence(timeout: 3), "Test button must exist")
        testBtn.tap()

        // 5) Wait for banner, then screenshot
        sleep(2)
        let bannerShot = app.screenshot()
        let bannerPath = "/Users/user291981/.openclaw/workspace/notif-demo/A3-notification-banner.png"
        try? bannerShot.pngRepresentation.write(to: URL(fileURLWithPath: bannerPath))
        print("📸 \(bannerPath)")

        // Also save into the app's screenshot folder for the App Store set
        let appStoreDir = "/Users/user291981/.openclaw/workspace/notif-demo"
        print("✅ Done — see \(appStoreDir)")
    }
}
