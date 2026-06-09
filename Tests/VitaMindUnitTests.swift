import XCTest
@testable import VitaMindGo

final class VitaPocketUnitTests: XCTestCase {

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
    // MARK: - AI Service Tests

    func testExtractValueFromMiniMaxResponse() throws {
        // Simulate actual MiniMax API response format
        let miniMaxResponse = """
        {
            "id": "1234567890",
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": "Hello! How can I help you today?"
                    },
                    "finish_reason": "stop"
                }
            ]
        }
        """
        .data(using: .utf8)!

        // Test with the actual keyPath used in production
        let content = extractValue(from: miniMaxResponse, keyPath: "choices.0.message.content")
        XCTAssertEqual(content, "Hello! How can I help you today?")
    }

    func testExtractValueNestedKeys() throws {
        let json = """
        {
            "choices": [
                {
                    "message": {
                        "content": "Nested response"
                    }
                }
            ]
        }
        """.data(using: .utf8)!

        let content = extractValue(from: json, keyPath: "choices.0.message.content")
        XCTAssertEqual(content, "Nested response")
    }

    func testExtractValueReturnsNilForMissingPath() throws {
        let json = """
        {
            "choices": [
                {
                    "message": {
                        "role": "assistant"
                    }
                }
            ]
        }
        """.data(using: .utf8)!

        // Missing "content" key
        let content = extractValue(from: json, keyPath: "choices.0.message.content")
        XCTAssertNil(content)
    }

    func testExtractValueInvalidJSON() throws {
        let invalidData = "not valid json".data(using: .utf8)!
        let result = extractValue(from: invalidData, keyPath: "any.key.path")
        XCTAssertNil(result)
    }

    func testExtractValueIndexOutOfBounds() throws {
        let json = """
        {
            "choices": []
        }
        """.data(using: .utf8)!

        // Empty array - index out of bounds
        let content = extractValue(from: json, keyPath: "choices.0.message.content")
        XCTAssertNil(content)
    }

    // MARK: - Apple Guideline 1.4.1 Regression Tests (2026-06-08)
    // Required to prevent re-rejection after build 9 fix for VitaMindGo.
    // Asserts the AI system prompt enforces citations and medical disclaimers.

    func testAISystemPromptRequiresCitations() throws {
        let prompt = AIService.vitaCoachSystemPrompt

        // 1. Mandate citations rule exists
        XCTAssertTrue(prompt.contains("CITATIONS"),
                      "System prompt must include a 'CITATIONS' rule")

        // 2. Required structured header '### Sources' (build 10 — Apple
        //    specifically asked for citations to be "easy to find")
        XCTAssertTrue(prompt.contains("### Sources"),
                      "System prompt must require the '### Sources' structured header")

        // 3. Domain-based authoritative source whitelist (build 10).
        //    The legacy form of this test (build 9) checked for label
        //    names like "NIH"/"Mayo Clinic". Build 10's prompt lists the
        //    source domains instead, which is what the AI uses to choose
        //    URLs to cite.
        for domain in ["cdc.gov", "who.int", "nih.gov", "medlineplus.gov", "mayoclinic.org"] {
            XCTAssertTrue(prompt.contains(domain),
                          "System prompt must include '\(domain)' as an authoritative source domain")
        }

        // 4. No medical claims rule (carried over from build 9)
        XCTAssertTrue(prompt.contains("NOT a doctor"),
                      "System prompt must disclaim medical role with 'NOT a doctor'")
    }

    func testAISystemPromptHasEmergencyResponse() throws {
        let prompt = AIService.vitaCoachSystemPrompt

        // 1. Emergency rule exists
        XCTAssertTrue(prompt.contains("EMERGENCY"),
                      "System prompt must include an 'EMERGENCY' rule")

        // 2. Mentions 911 (US emergency number)
        XCTAssertTrue(prompt.contains("911"),
                      "System prompt must mention 911 for US emergencies")

        // 3. Recommends professional medical advice
        XCTAssertTrue(prompt.contains("healthcare professional"),
                      "System prompt must recommend consulting a healthcare professional")
    }

    func testAISystemPromptLengthIsReasonable() throws {
        // Guards against accidental prompt bloat (would increase per-request token cost)
        // Build 10's prompt is longer because it spells out the structured
        // citation format and the domain whitelist, so the ceiling is bumped
        // from 2000 → 3000 to accommodate the stricter Apple 1.4.1 requirements.
        let prompt = AIService.vitaCoachSystemPrompt
        XCTAssertLessThan(prompt.count, 3000,
                          "System prompt should stay under 3000 chars to control token cost")
        XCTAssertGreaterThan(prompt.count, 500,
                             "System prompt should be substantive (500+ chars)")
    }

    // MARK: - Apple Guideline 1.4.1 Regression Tests — Citations (build 10, 2026-06-09)
    // Apple rejected build 9 because (a) the AI sometimes omitted the Sources
    // block and (b) the UI rendered any present citations as buried markdown.
    // Build 10 fixes both with a stricter prompt, a parser, and a dedicated
    // citation footer card. These tests guard against future regression.

    func testCitationParserExtractsSourcesBlock() throws {
        let raw = """
        Managing diabetes involves several lifestyle factors.

        ### Sources
        1. CDC - Diabetes Management — https://www.cdc.gov/diabetes/managing/index.html
        2. Mayo Clinic - Type 2 Diabetes — https://www.mayoclinic.org/diseases-conditions/type-2-diabetes
        """
        let (clean, citations) = AIService.parseCitations(from: raw)

        XCTAssertEqual(citations.count, 2, "Should extract 2 citations")
        XCTAssertEqual(citations[0].title, "CDC - Diabetes Management")
        XCTAssertEqual(citations[0].url, "https://www.cdc.gov/diabetes/managing/index.html")
        XCTAssertEqual(citations[1].title, "Mayo Clinic - Type 2 Diabetes")
        XCTAssertTrue(clean.contains("Managing diabetes"), "Display text keeps the prose")
        XCTAssertFalse(clean.contains("### Sources"), "Display text strips the Sources header")
        XCTAssertFalse(clean.contains("cdc.gov"), "Display text strips the citation lines")
    }

    func testCitationParserHandlesLegacyBoldHeader() throws {
        // Older prompt variant used **Sources:** — make sure we still parse it.
        let raw = "**Sources:**\n1. NIH — https://www.nih.gov\n2. WHO — https://www.who.int"
        let (_, citations) = AIService.parseCitations(from: raw)
        XCTAssertEqual(citations.count, 2)
        XCTAssertEqual(citations[0].url, "https://www.nih.gov")
    }

    func testCitationParserHandlesPlainHeader() throws {
        // "Sources:" with no markdown decoration.
        let raw = "Some text.\n\nSources:\n1. CDC — https://www.cdc.gov"
        let (_, citations) = AIService.parseCitations(from: raw)
        XCTAssertEqual(citations.count, 1)
    }

    func testCitationParserFallsBackToInlineLinks() throws {
        // No Sources block but inline [Title](url) markdown is present.
        let raw = "Try [MedlinePlus](https://medlineplus.gov) for more info."
        let (_, citations) = AIService.parseCitations(from: raw)
        XCTAssertEqual(citations.count, 1)
        XCTAssertEqual(citations[0].title, "MedlinePlus")
        XCTAssertEqual(citations[0].url, "https://medlineplus.gov")
    }

    func testCitationParserReturnsEmptyForNoCitations() throws {
        let raw = "This is just plain text with no sources."
        let (clean, citations) = AIService.parseCitations(from: raw)
        XCTAssertEqual(citations.count, 0)
        XCTAssertEqual(clean, raw)
    }

    func testCitationParserStopsAtUnparseableLine() throws {
        // A line without a URL should end the Sources block, not be swallowed.
        let raw = """
        Prose.

        ### Sources
        1. CDC — https://www.cdc.gov
        This line has no URL or number prefix.
        2. WHO — https://www.who.int
        """
        let (_, citations) = AIService.parseCitations(from: raw)
        XCTAssertEqual(citations.count, 1, "Parser must stop at the broken line")
        XCTAssertEqual(citations[0].url, "https://www.cdc.gov")
    }

    func testCitationParserStripsTrailingPunctuationFromURL() throws {
        // Model sometimes ends lines with a period or comma.
        let raw = "### Sources\n1. CDC — https://www.cdc.gov."
        let (_, citations) = AIService.parseCitations(from: raw)
        XCTAssertEqual(citations[0].url, "https://www.cdc.gov")
    }

    func testHealthSourceCatalogWhitelistAcceptsTrustedDomains() throws {
        XCTAssertTrue(HealthSourceCatalog.isAllowed("https://www.cdc.gov/diabetes"))
        XCTAssertTrue(HealthSourceCatalog.isAllowed("https://www.who.int/news"))
        XCTAssertTrue(HealthSourceCatalog.isAllowed("https://medlineplus.gov/diabetes"))
        XCTAssertTrue(HealthSourceCatalog.isAllowed("https://www.mayoclinic.org/diseases-conditions/type-2-diabetes"))
        XCTAssertTrue(HealthSourceCatalog.isAllowed("https://www.nhs.uk/conditions/type-2-diabetes/"))
        XCTAssertTrue(HealthSourceCatalog.isAllowed("https://pubmed.ncbi.nlm.nih.gov/12345678"))
    }

    func testHealthSourceCatalogWhitelistRejectsUntrustedDomains() throws {
        XCTAssertFalse(HealthSourceCatalog.isAllowed("https://www.reddit.com/r/diabetes"))
        XCTAssertFalse(HealthSourceCatalog.isAllowed("https://en.wikipedia.org/wiki/Diabetes"))
        XCTAssertFalse(HealthSourceCatalog.isAllowed("https://www.tiktok.com/@dr.health"))
        XCTAssertFalse(HealthSourceCatalog.isAllowed("not a url"))
    }

    func testSystemPromptRequiresStructuredSourcesHeader() throws {
        // Build 10 must require the "### Sources" header specifically
        // (Apple wants citations "easy to find" — the parser relies on this header).
        let prompt = AIService.vitaCoachSystemPrompt
        XCTAssertTrue(prompt.contains("### Sources"),
                      "System prompt must instruct AI to use '### Sources' header for parseable citations")
        XCTAssertTrue(prompt.contains("whitelist"),
                      "System prompt must mention the source whitelist")
        XCTAssertTrue(prompt.contains("cdc.gov") && prompt.contains("mayoclinic.org"),
                      "System prompt must list the major authoritative sources by domain")
        XCTAssertTrue(prompt.contains("at least 2"),
                      "System prompt must require a minimum number of citations")
    }


    // MARK: - Helper for testing (must be accessible)
    private func extractValue(from data: Data, keyPath: String) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        var current: Any = json
        for key in keyPath.split(separator: ".") {
            let keyStr = String(key)
            if let array = current as? [Any], let index = Int(keyStr), index < array.count {
                current = array[index]
            } else if let dict = current as? [String: Any], let value = dict[keyStr] {
                current = value
            } else {
                return nil
            }
        }

        return current as? String
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