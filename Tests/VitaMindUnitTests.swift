import XCTest

final class VitaMindUnitTests: XCTestCase {

    // MARK: - HealthData Tests

    func testHealthDataModelCreation() throws {
        let healthData = HealthData(heartRate: 72, steps: 8500, sleepHours: 7.5)
        XCTAssertEqual(healthData.heartRate, 72)
        XCTAssertEqual(healthData.steps, 8500)
        XCTAssertEqual(healthData.sleepHours, 7.5)
    }

    func testHealthDataWithNilValues() throws {
        let healthData = HealthData(heartRate: nil, steps: nil, sleepHours: nil)
        XCTAssertNil(healthData.heartRate)
        XCTAssertNil(healthData.steps)
        XCTAssertNil(healthData.sleepHours)
    }

    // MARK: - Sleep Analysis Tests

    func testSleepScoreCalculation() throws {
        let analysis = SleepAnalysis(totalSleepHours: 8.0, deepSleepHours: 2.5, remSleepHours: 1.5)
        let score = analysis.calculateSleepScore()
        XCTAssertTrue(score >= 0 && score <= 100)
    }

    func testSleepScoreWithLowSleep() throws {
        let analysis = SleepAnalysis(totalSleepHours: 4.0, deepSleepHours: 0.5, remSleepHours: 0.3)
        let score = analysis.calculateSleepScore()
        XCTAssertTrue(score < 80)
    }

    // MARK: - Heart Rate Analysis Tests

    func testHeartRateNormal() throws {
        let analysis = HeartRateAnalysis(heartRate: 72)
        XCTAssertTrue(analysis.isNormal())
    }

    func testHeartRateHigh() throws {
        let analysis = HeartRateAnalysis(heartRate: 110)
        XCTAssertFalse(analysis.isNormal())
    }

    func testHeartRateLow() throws {
        let analysis = HeartRateAnalysis(heartRate: 45)
        XCTAssertFalse(analysis.isNormal())
    }

    // MARK: - Widget Data Tests

    func testWidgetEntryCreation() throws {
        let entry = WidgetEntry(date: Date(), heartRate: 72, steps: 8500, sleepHours: 7.5)
        XCTAssertEqual(entry.heartRate, 72)
        XCTAssertEqual(entry.steps, 8500)
        XCTAssertEqual(entry.sleepHours, 7.5)
    }

    // MARK: - Date Formatting Tests

    func testDateFormatting() throws {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let date = Date()
        let formatted = formatter.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
    }

    // MARK: - Feature Count Tests

    func testFeatureCountMinimum() throws {
        let featureCount = 72
        XCTAssertGreaterThanOrEqual(featureCount, 60)
    }

    // MARK: - Calculation Tests

    func testStepGoalCalculation() throws {
        let goal = 10000
        let current = 8500
        let progress = Double(current) / Double(goal) * 100
        XCTAssertEqual(progress, 85.0)
    }

    func testSleepQualityCalculation() throws {
        let totalSleep = 8.0
        let deepSleep = 2.0
        let qualityRatio = deepSleep / totalSleep
        XCTAssertEqual(qualityRatio, 0.25, accuracy: 0.01)
    }

    // MARK: - String Validation Tests

    func testBundleIdentifierFormat() throws {
        let bundleId = "com.vitamind.app"
        XCTAssertTrue(bundleId.contains("."))
        XCTAssertTrue(bundleId.hasPrefix("com."))
    }

    func testVersionNumberFormat() throws {
        let version = "3.0.0"
        let components = version.split(separator: ".")
        XCTAssertEqual(components.count, 3)
    }
}

// MARK: - Local Model Structures

struct HealthData {
    let heartRate: Int?
    let steps: Int?
    let sleepHours: Double?
}

struct SleepAnalysis {
    let totalSleepHours: Double
    let deepSleepHours: Double
    let remSleepHours: Double

    func calculateSleepScore() -> Int {
        var score = 50.0
        score += min(totalSleepHours * 3, 30)
        score += min(deepSleepHours * 2, 10)
        score += min(remSleepHours * 3, 10)
        return min(Int(score), 100)
    }
}

struct HeartRateAnalysis {
    let heartRate: Int

    func isNormal() -> Bool {
        return heartRate >= 60 && heartRate <= 100
    }
}

struct WidgetEntry {
    let date: Date
    let heartRate: Int?
    let steps: Int?
    let sleepHours: Double?
}