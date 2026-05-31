import XCTest

// MARK: - Shared Tab Helper
extension XCTestCase {
    func tapTabButton(in app: XCUIApplication, label: String) {
        // Direct coordinate-based tapping - works on all devices consistently
        let tabIndexMap = ["Pocket": 0, "Habits": 1, "Coach": 2, "Collection": 3]
        guard let targetIndex = tabIndexMap[label] else { return }
        
        // Calculate normalized position: each tab gets 1/4 of screen width
        // Tab centers at: 0.125 (Pocket), 0.375 (Habits), 0.625 (Coach), 0.875 (Collection)
        let normalizedX = (CGFloat(targetIndex) + 0.5) / 4.0
        let normalizedY: CGFloat = 0.96  // Near bottom of screen (tab bar area)
        
        let coordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: normalizedX, dy: normalizedY))
        coordinate.tap()
        
        // Wait for tab switch animation to complete
        Thread.sleep(forTimeInterval: 2.0)
        print("✓ Tapped tab: \(label) at (\(String(format: "%.3f", normalizedX)), \(String(format: "%.3f", normalizedY)))")
    }
    
    func captureScreenshot(in app: XCUIApplication, name: String) {
        let path = "/tmp/\(name).png"
        let image = app.windows.firstMatch.screenshot()
        let data = image.pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
        print("📸 Captured: \(path)")
        
        // Verify file exists and has content
        if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
           let size = attrs[.size] as? Int {
            print("   Size: \(size) bytes")
        }
    }
}

// MARK: - iPhone 17 Pro Max Tests

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

    func testAllTabs() {
        print("=== iPhone 17 Pro Max - Capturing screenshots ===")
        
        // Tab 1: Pocket
        captureScreenshot(in: app, name: "vp_tab1_pocket")
        
        // Tab 2: Habits
        tapTabButton(in: app, label: "Habits")
        captureScreenshot(in: app, name: "vp_tab2_habits")
        
        // Tab 3: Coach
        tapTabButton(in: app, label: "Coach")
        captureScreenshot(in: app, name: "vp_tab3_coach")
        
        // Tab 4: Collection
        tapTabButton(in: app, label: "Collection")
        captureScreenshot(in: app, name: "vp_tab4_collection")
        
        print("=== iPhone 17 Pro Max - All tabs captured ===")
    }
}

// MARK: - iPad Pro 13-inch (M4) Tests

final class VitaPocketiPadTests: XCTestCase {

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

    func testAllTabs() {
        print("=== iPad Pro 13-inch (M4) - Capturing screenshots ===")
        
        // Tab 1: Pocket
        captureScreenshot(in: app, name: "ipad_tab1_pocket")
        
        // Tab 2: Habits
        tapTabButton(in: app, label: "Habits")
        captureScreenshot(in: app, name: "ipad_tab2_habits")
        
        // Tab 3: Coach
        tapTabButton(in: app, label: "Coach")
        captureScreenshot(in: app, name: "ipad_tab3_coach")
        
        // Tab 4: Collection
        tapTabButton(in: app, label: "Collection")
        captureScreenshot(in: app, name: "ipad_tab4_collection")
        
        print("=== iPad Pro 13-inch (M4) - All tabs captured ===")
    }
}

// MARK: - Apple Watch Ultra 3 Tests

final class VitaPocketWatchTests: XCTestCase {

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

    func testMainView() {
        print("=== Apple Watch Ultra 3 - Capturing screenshot ===")
        captureScreenshot(in: app, name: "watch_tab1_main")
        print("=== Apple Watch Ultra 3 - Captured ===")
    }
}