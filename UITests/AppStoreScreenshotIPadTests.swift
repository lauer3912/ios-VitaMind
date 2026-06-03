import XCTest

/// One-off: walk every tab in dark mode on iPad Pro 13" (M4) and
/// capture a 2048x2732 screenshot for the App Store listing.
/// Replaces the legacy-5-31 captures (only 4 tabs, no empty state UI).
final class AppStoreScreenshotIPadTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        // Register the interruption monitor in setUp() so it's in
        // place before any test method runs. The notification
        // permission alert fires on first launch and would otherwise
        // cover the tab content.
        self.addUIInterruptionMonitor(withDescription: "Notification Permission") { (alert) -> Bool in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            return false
        }
    }

    func testCaptureAllTabsIPad() throws {
        // iPad TabView with .automatic style is page-style on iPadOS,
        // and swipe/tap-to-switch is unreliable in XCUITest. Instead,
        // we boot the app once per tab and set VITA_INITIAL_TAB so
        // ContentView lands on the right tab on launch.
        let outDir = "/Users/user291981/Desktop/ios-VitaMind/AppStore/Screenshots/iPadPro13inchM4_2048x2732"
        let tabs: [(index: Int, label: String, file: String)] = [
            (0, "Pocket",     "ipad_tab1.png"),
            (1, "Habits",     "ipad_tab2.png"),
            (2, "Coach",      "ipad_tab3.png"),
            (3, "Collection", "ipad_tab4.png"),
            (4, "Settings",   "ipad_tab5_settings.png"),
        ]

        for tab in tabs {
            let app = XCUIApplication()
            app.launchArguments += ["--uitesting"]
            app.launchEnvironment = ["VITA_INITIAL_TAB": String(tab.index)]

            app.launch()
            // Brief settle so the notification permission alert has
            // time to appear (iOS shows it ~1s after first launch).
            sleep(2)

            // The notification permission alert is a system-level
            // alert, not an in-app alert — app.alerts can't see it.
            // The interruption monitor (registered in setUp) handles
            // it, but XCUITest only invokes the monitor after a user
            // gesture. Tap the very top-left corner of the iPad screen
            // (which is outside any app UI) to trigger the monitor.
            let window = app.windows.firstMatch
            let topLeft = window.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.01))
            topLeft.tap()
            sleep(2)

            let path = "\(outDir)/\(tab.file)"
            let shot = app.screenshot()
            try? shot.pngRepresentation.write(to: URL(fileURLWithPath: path))
            print("📸 iPad \(tab.label) → \(path)")

            app.terminate()
        }
    }
}
