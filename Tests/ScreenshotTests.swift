import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        Thread.sleep(forTimeInterval: 2.0)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Helper Methods

    private func capture(_ name: String) {
        let path = "/tmp/\(name).png"
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
        print("📸 Captured: \(name) -> \(path)")
    }

    private func tapTab(named label: String, wait: TimeInterval = 2.0) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", label)
        let button = app.buttons.matching(predicate).firstMatch
        if button.waitForExistence(timeout: 5) && button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: wait)
        } else {
            print("⚠️ Button not found: \(label)")
        }
    }

    // MARK: - iPhone 17 Pro Screenshots (1320x2868)

    func testScreenshot_iPhone17Pro_Health() {
        tapTab(named: "Health")
        capture("iPhone17Pro_Health")
    }

    func testScreenshot_iPhone17Pro_Habits() {
        tapTab(named: "Habits")
        capture("iPhone17Pro_Habits")
    }

    func testScreenshot_iPhone17Pro_AI() {
        tapTab(named: "AI")
        capture("iPhone17Pro_AI")
    }

    func testScreenshot_iPhone17Pro_Settings() {
        tapTab(named: "Settings")
        capture("iPhone17Pro_Settings")
    }

    // MARK: - iPad Pro Screenshots (2048x2732)

    func testScreenshot_iPadPro_Health() {
        tapTab(named: "Health")
        capture("iPadPro_Health")
    }

    func testScreenshot_iPadPro_Habits() {
        tapTab(named: "Habits")
        capture("iPadPro_Habits")
    }

    func testScreenshot_iPadPro_AI() {
        tapTab(named: "AI")
        capture("iPadPro_AI")
    }

    func testScreenshot_iPadPro_Settings() {
        tapTab(named: "Settings")
        capture("iPadPro_Settings")
    }
}