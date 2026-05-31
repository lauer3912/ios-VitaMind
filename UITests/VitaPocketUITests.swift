import XCTest

// MARK: - Shared Tab Helper
extension XCTestCase {
    func tapTabButton(in app: XCUIApplication, label: String) {
        let indexMap = ["Pocket": 0, "Habits": 1, "Coach": 2, "Collection": 3]
        guard let targetIndex = indexMap[label] else { return }
        
        // Get window
        let window = app.windows.firstMatch
        let frame = window.frame
        
        // Use swipe gestures on the content area to switch tabs
        // In SwiftUI TabView, swiping left/right changes tabs
        // We need to swipe from right-to-left to go forward (next tab)
        let swipeCount = targetIndex  // Start from tab 0, swipe N times to get to tab N
        
        // Swipe on the main content area (center of screen)
        let centerY = frame.height * 0.5  // Middle of screen
        
        for _ in 0..<swipeCount {
            // XCTest swipe uses velocity, so this should work on TabView
            window.swipeLeft()
            Thread.sleep(forTimeInterval: 1.0)
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        print("✓ Switched to tab: \(label) via \(swipeCount) swipe(s)")
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