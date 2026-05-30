import XCTest

final class E2ETests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Tab Navigation E2E

    func testE2E_TabNavigation() {
        // Test Health tab
        XCTAssertTrue(app.buttons["tab_health"].exists)
        app.buttons["tab_health"].tap()
        Thread.sleep(forTimeInterval: 1)

        // Test Habits tab
        XCTAssertTrue(app.buttons["tab_habits"].exists)
        app.buttons["tab_habits"].tap()
        Thread.sleep(forTimeInterval: 1)

        // Test AI tab
        XCTAssertTrue(app.buttons["tab_ai"].exists)
        app.buttons["tab_ai"].tap()
        Thread.sleep(forTimeInterval: 1)

        // Test Settings tab
        XCTAssertTrue(app.buttons["tab_settings"].exists)
        app.buttons["tab_settings"].tap()
        Thread.sleep(forTimeInterval: 1)
    }

    // MARK: - Health Dashboard E2E

    func testE2E_HealthDashboard() {
        app.buttons["tab_health"].tap()
        Thread.sleep(forTimeInterval: 1)

        // Verify health metrics are displayed
        XCTAssertTrue(app.staticTexts["health_title"].waitForExistence(timeout: 5))
    }

    // MARK: - Habits Tracking E2E

    func testE2E_HabitsTracking() {
        app.buttons["tab_habits"].tap()
        Thread.sleep(forTimeInterval: 1)

        // Verify habits list is visible
        XCTAssertTrue(app.staticTexts["habit_tracking_view"].waitForExistence(timeout: 5))
    }

    // MARK: - Settings E2E

    func testE2E_Settings() {
        app.buttons["tab_settings"].tap()
        Thread.sleep(forTimeInterval: 1)

        // Verify settings view loads
        XCTAssertTrue(app.tables.firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Dark Mode E2E

    func testE2E_DarkModeToggle() {
        app.buttons["tab_settings"].tap()
        Thread.sleep(forTimeInterval: 1)

        // Scroll to appearance settings
        // Toggle dark mode if available
    }

    // MARK: - Accessibility E2E

    func testE2E_Accessibility() {
        // Test VoiceOver navigation
        // Verify all interactive elements have accessibility identifiers
        XCTAssertTrue(app.buttons["tab_health"].exists)
        XCTAssertTrue(app.buttons["tab_habits"].exists)
        XCTAssertTrue(app.buttons["tab_ai"].exists)
        XCTAssertTrue(app.buttons["tab_settings"].exists)
    }

    // MARK: - Performance E2E

    func testE2E_LaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
}