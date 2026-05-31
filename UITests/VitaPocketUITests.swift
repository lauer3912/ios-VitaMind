import XCTest

final class VitaPocketUITests: XCTestCase {

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

    private func capture(_ name: String) {
        let path = "/tmp/\(name).png"
        let image = app.windows.firstMatch.screenshot()
        let data = image.pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
        print("📸 \(name)")
    }

    private func tapTab(_ label: String) {
        let button = app.buttons[label]
        button.tap()
        Thread.sleep(forTimeInterval: 1.5)
        print("Tapped tab: \(label)")
    }

    func testAllTabs() {
        // Tab 1: Pocket
        capture("vp_tab1_pocket")
        
        // Tab 2: Habits
        tapTab("Habits")
        capture("vp_tab2_habits")
        
        // Tab 3: Coach
        tapTab("Coach")
        capture("vp_tab3_coach")
        
        // Tab 4: Collection
        tapTab("Collection")
        capture("vp_tab4_collection")
        
        // Keep app running for manual verification
        Thread.sleep(forTimeInterval: 2.0)
    }
}
