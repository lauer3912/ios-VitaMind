import XCTest

// MARK: - Shared Tab Helper
extension XCTestCase {
    func tapTabButton(in app: XCUIApplication, label: String) {
        // SwiftUI TabView on iPad: swipe on content area to switch tabs
        let indexMap = ["Pocket": 0, "Habits": 1, "Coach": 2, "Collection": 3]
        guard let targetIndex = indexMap[label] else { return }
        
        let window = app.windows.firstMatch
        let frame = window.frame
        
        // Swipe left on center of content to advance tabs
        // Each swipe goes to next tab
        for _ in 0..<targetIndex {
            window.swipeLeft()
            Thread.sleep(forTimeInterval: 1.5)
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        print("✓ Switched to tab: \(label) via swipe (\(targetIndex) swipes)")
    }
    
    func captureScreenshot(in app: XCUIApplication, name: String) {
        let path = "/tmp/\(name).png"
        let image = app.windows.firstMatch.screenshot()
        let data = image.pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
        print("📸 Captured: \(path)")
        
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

// MARK: - Debug Test

final class DebugTabBarTest: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        Thread.sleep(forTimeInterval: 3.0)
    }

    func testFindTabBarElements() {
        print("=== Tab Bar Debug ===")
        
        // Check if tab bar exists
        let tabBars = app.tabBars
        print("Tab bars found: \(tabBars.count)")
        
        if tabBars.count > 0 {
            let buttons = tabBars.firstMatch.buttons
            print("Tab bar buttons: \(buttons.count)")
            
            for i in 0..<buttons.count {
                let btn = buttons.element(boundBy: i)
                print("  Button \(i): label='\(btn.label)', id='\(btn.identifier)', exists=\(btn.exists)")
            }
        }
        
        // Check all descendants
        let allElements = app.descendants(matching: .any)
        print("Total descendants: \(allElements.count)")
        
        for i in 0..<min(30, allElements.count) {
            let el = allElements.element(boundBy: i)
            if el.exists && !el.label.isEmpty {
                print("[\(i)] \(el.elementType.rawValue): '\(el.label)' id='\(el.identifier)'")
            }
        }
    }
}

// MARK: - iPad simctl Screenshot Test

final class VitaPocketiPadSimctlTests: XCTestCase {
    var app: XCUIApplication!
    private let deviceID = "836FC318-4372-4818-94EA-24697D147455"

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

    func testCaptureAllTabsSimctl() {
        print("=== iPad simctl Screenshot Test ===")
        
        let window = app.windows.firstMatch
        let frame = window.frame
        
        // Tab 0: Pocket
        print("Tab 0: Pocket")
        captureSimctl(name: "ipad_simctl_0")
        
        // Calculate tab positions for direct coordinate tap
        let tabBarY = frame.height - 80
        let tabWidth = frame.width / 4
        
        // Tab 1: Habits - tap at position 1
        print("Tab 1: Habits - tapping at y=\(Int(tabBarY))")
        let coord1 = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            .withOffset(CGVector(dx: tabWidth * 1 + tabWidth/2, dy: tabBarY))
        coord1.tap()
        Thread.sleep(forTimeInterval: 2.5)
        captureSimctl(name: "ipad_simctl_1")
        
        // Tab 2: Coach - tap at position 2
        print("Tab 2: Coach - tapping at y=\(Int(tabBarY))")
        let coord2 = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            .withOffset(CGVector(dx: tabWidth * 2 + tabWidth/2, dy: tabBarY))
        coord2.tap()
        Thread.sleep(forTimeInterval: 2.5)
        captureSimctl(name: "ipad_simctl_2")
        
        // Tab 3: Collection - tap at position 3
        print("Tab 3: Collection - tapping at y=\(Int(tabBarY))")
        let coord3 = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            .withOffset(CGVector(dx: tabWidth * 3 + tabWidth/2, dy: tabBarY))
        coord3.tap()
        Thread.sleep(forTimeInterval: 2.5)
        captureSimctl(name: "ipad_simctl_3")
        
        print("=== Done ===")
    }
    
    private func captureSimctl(name: String) {
        // This is a placeholder - actual capture happens via xcrun in shell
        // We just log here
        print("  Should capture: \(name)")
    }
}
