import XCTest

final class VitaMindUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        Thread.sleep(forTimeInterval: 3.0)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Helper Methods

    private func capture(_ name: String) {
        let path = "/tmp/\(name).png"
        let image = app.windows.firstMatch.screenshot()
        let data = image.pngRepresentation
        do {
            try data.write(to: URL(fileURLWithPath: path))
            print("📸 Captured: \(name) -> \(path)")
        } catch {
            print("❌ Failed to write \(name): \(error)")
        }
    }

    private func tapTab(identifier: String, wait: TimeInterval = 2.0) {
        let button = app.buttons[identifier]
        if button.waitForExistence(timeout: 10) && button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: wait)
            print("✅ Tapped tab: \(identifier)")
        } else {
            print("⚠️ Button not found: \(identifier)")
            print("   Available buttons: \(app.buttons.allElementsBoundByIndex.map { $0.identifier }.prefix(10))")
        }
    }

    // MARK: - iPhone 17 Pro Screenshots (1320x2868)

    func testScreenshot_iPhone17Pro_Health() {
        tapTab(identifier: "tab_health")
        capture("iPhone17Pro_Health")
    }

    func testScreenshot_iPhone17Pro_Habits() {
        tapTab(identifier: "tab_habits")
        capture("iPhone17Pro_Habits")
    }

    func testScreenshot_iPhone17Pro_AI() {
        tapTab(identifier: "tab_ai")
        capture("iPhone17Pro_AI")
    }

    func testScreenshot_iPhone17Pro_Settings() {
        tapTab(identifier: "tab_settings")
        capture("iPhone17Pro_Settings")
    }

    // MARK: - iPad Pro Screenshots (2048x2732)

    func testScreenshot_iPadPro_Health() {
        tapTab(identifier: "tab_health")
        capture("iPadPro_Health")
    }

    func testScreenshot_iPadPro_Habits() {
        tapTab(identifier: "tab_habits")
        capture("iPadPro_Habits")
    }

    func testScreenshot_iPadPro_AI() {
        tapTab(identifier: "tab_ai")
        capture("iPadPro_AI")
    }

    func testScreenshot_iPadPro_Settings() {
        tapTab(identifier: "tab_settings")
        capture("iPadPro_Settings")
    }
}