import XCTest

/// One-off: walk every tab in dark mode and capture a 1320x2868
/// screenshot for the App Store listing. Replaces the legacy-5-31
/// captures which lacked the Settings tab and post-mock-removal UI.
final class AppStoreScreenshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testCaptureAllTabsDarkMode() throws {
        let app = XCUIApplication()
        app.launchArguments += ["--uitesting"]

        // Auto-accept the notification permission prompt
        addUIInterruptionMonitor(withDescription: "Notification Permission") { (alert) -> Bool in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            return false
        }

        app.launch()
        app.swipeUp()
        sleep(1)
        app.tap()
        sleep(3) // let any alert dismiss

        let outDir = "/Users/user291981/Desktop/ios-VitaMind/AppStore/Screenshots/iPhone17ProMax_1320x2868"
        let tabs: [(label: String, file: String, settle: Double)] = [
            ("Pocket",     "vp_tab1_pocket.png",     2.0),
            ("Habits",     "vp_tab2_habits.png",     2.0),
            ("Coach",      "vp_tab3_coach.png",      2.0),
            ("Collection", "vp_tab4_collection.png", 2.0),
            ("Settings",   "vp_tab5_settings.png",   2.0),
        ]

        for (i, tab) in tabs.enumerated() {
            // Tap the tab. iPhone TabView exposes tabs via tabBars.buttons
            // consistently. If the label is missing (e.g. on iPad page
            // style), fall back to swipe navigation.
            let tabButton = app.tabBars.buttons[tab.label]
            if tabButton.waitForExistence(timeout: 3) {
                tabButton.tap()
            } else {
                // Fallback: swipe from current to target
                let current = i
                for _ in 0..<current {
                    app.swipeLeft()
                    sleep(1)
                }
            }
            Thread.sleep(forTimeInterval: tab.settle)

            let path = "\(outDir)/\(tab.file)"
            let shot = app.screenshot()
            try? shot.pngRepresentation.write(to: URL(fileURLWithPath: path))
            print("📸 \(tab.label) → \(path)")
        }
    }
}
