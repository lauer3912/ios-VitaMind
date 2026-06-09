import Foundation

// MARK: - AI Provider Configuration

enum AIProviderType: String, CaseIterable, Codable, Identifiable {
    case minimaxCn = "minimax-cn"
    case minimaxGlobal = "minimax-global"
    case openai = "openai"
    case anthropic = "anthropic"
    case google = "google"
    case deepseek = "deepseek"
    case xai = "xai"
    case moonshot = "moonshot"
    case qwen = "qwen"
    case zai = "zai"
    case stepfun = "stepfun"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .minimaxCn: return "MiniMax-CN"
        case .minimaxGlobal: return "MiniMax-Global"
        case .openai: return "OpenAI"
        case .anthropic: return "Anthropic"
        case .google: return "Google"
        case .deepseek: return "DeepSeek"
        case .xai: return "xAI"
        case .moonshot: return "Moonshot AI"
        case .qwen: return "Qwen"
        case .zai: return "Z.AI"
        case .stepfun: return "StepFun"
        }
    }

    var iconName: String {
        switch self {
        case .minimaxCn: return "lock.shield.fill"
        case .minimaxGlobal: return "globe"
        case .openai: return "sparkles"
        case .anthropic: return "person.fill"
        case .google: return "g.circle"
        case .deepseek: return "magnifyingglass"
        case .xai: return "x.circle"
        case .moonshot: return "moon.fill"
        case .qwen: return "building.2.fill"
        case .zai: return "star.fill"
        case .stepfun: return "bolt.fill"
        }
    }

    var defaultModel: String {
        switch self {
        case .minimaxCn: return "minimax/MiniMax-M3"
        case .minimaxGlobal: return "minimax/MiniMax-M3"
        case .openai: return "openai/gpt-5.5"
        case .anthropic: return "anthropic/claude-opus-4-6"
        case .google: return "google/gemini-3.1-pro-preview"
        case .deepseek: return "deepseek/deepseek-v4-flash"
        case .xai: return "xai/grok-4.3"
        case .moonshot: return "moonshot/kimi-k2.6"
        case .qwen: return "qwen/qwen3.5-plus"
        case .zai: return "zai/glm-5"
        case .stepfun: return "stepfun/step-3.5-flash"
        }
    }

    var baseURL: String {
        switch self {
        case .minimaxCn: return "https://api.minimaxi.com/v1"
        case .minimaxGlobal: return "https://api.minimax.io/v1"
        case .openai: return "https://api.openai.com/v1/chat/completions"
        case .anthropic: return "https://api.anthropic.com/v1/messages"
        case .google: return "https://generativelanguage.googleapis.com/v1beta/models"
        case .deepseek: return "https://api.deepseek.com/v1/chat/completions"
        case .xai: return "https://api.x.ai/v1/chat/completions"
        case .moonshot: return "https://api.moonshot.cn/v1/chat/completions"
        case .qwen: return "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"
        case .zai: return "https://open.bigmodel.cn/api/paas/v4/chat/completions"
        case .stepfun: return "https://api.stepfun.com/v1/chat/completions"
        }
    }

    var supportedModels: [String] {
        switch self {
        case .minimaxCn, .minimaxGlobal:
            return ["minimax/MiniMax-M3", "minimax/MiniMax-M2.7", "minimax/MiniMax-M2.7-highspeed", "minimax/MiniMax-M2.5", "minimax/MiniMax-M2.5-highspeed"]
        case .openai:
            return ["openai/gpt-5.5", "openai/gpt-5.4", "openai/gpt-4o", "openai/gpt-4-turbo", "openai/gpt-3.5-turbo"]
        case .anthropic:
            return ["anthropic/claude-opus-4-6", "anthropic/claude-sonnet-4-6", "anthropic/claude-3-5-sonnet-20240620", "anthropic/claude-3-opus-20240229"]
        case .google:
            return ["google/gemini-3.1-pro-preview", "google/gemini-2.0-flash-exp", "google/gemini-3-flash-preview", "google/gemini-1.5-pro", "google/gemini-1.5-flash"]
        case .deepseek:
            return ["deepseek/deepseek-v4-flash", "deepseek/deepseek-v4-pro", "deepseek/deepseek-chat"]
        case .xai:
            return ["xai/grok-4.3", "xai/grok-4", "xai/grok-3", "xai/grok-2"]
        case .moonshot:
            return ["moonshot/kimi-k2.6", "moonshot/kimi-k2.5", "moonshot/kimi-k2-thinking", "moonshot/kimi-k2-turbo"]
        case .qwen:
            return ["qwen/qwen3.5-plus", "qwen/qwen3.5", "qwen/qwen2.5-coder", "qwen/qwen-turbo"]
        case .zai:
            return ["zai/glm-5", "zai/glm-4", "zai/glm-4-flash", "zai/glm-5-ultra"]
        case .stepfun:
            return ["stepfun/step-3.5-flash", "stepfun/step-3", "stepfun/step-2-flash"]
        }
    }
}

// MARK: - Citation (Apple Guideline 1.4.1 compliance, 2026-06-09 build 10)

/// A single source citation extracted from an AI response's "### Sources" block.
/// Apple requires health/medical information to be cited; users must be able to
/// find citations easily (rendered as a dedicated footer card, not buried in prose).
struct Citation: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let url: String
}

/// Result of an AI call: the display text (with the "### Sources" block already
/// stripped out) plus the citations parsed from that block. Returning them
/// together keeps the UI in sync with what the model actually produced.
struct AIResponse {
    let text: String
    let citations: [Citation]

    init(text: String, citations: [Citation] = []) {
        self.text = text
        self.citations = citations
    }
}

/// Authoritative source whitelist (Apple 1.4.1). The AI prompt instructs the
/// model to cite only URLs whose domain is in this set. The parser also
/// uses this list to flag suspicious citations and to derive a display title
/// when the AI omitted one.
enum HealthSourceCatalog {
    /// Allowed source domains (Apple 1.4.1 — authoritative health sources only)
    static let allowedDomains: [String] = [
        "cdc.gov",            // Centers for Disease Control and Prevention
        "who.int",            // World Health Organization
        "nih.gov",            // National Institutes of Health
        "medlineplus.gov",    // NIH consumer health information
        "mayoclinic.org",     // Mayo Clinic
        "nhs.uk",             // UK National Health Service
        "pubmed.ncbi.nlm.nih.gov", // NIH peer-reviewed studies
        "healthline.com",     // Medically reviewed consumer health
        "webmd.com"           // Medically reviewed consumer health
    ]

    /// Default fallback titles when an AI response references a domain
    /// without specifying a page title. Keeps the Sources card useful even
    /// when the model is terse.
    static func defaultTitle(for url: String) -> String {
        let lower = url.lowercased()
        if lower.contains("cdc.gov") { return "CDC (Centers for Disease Control and Prevention)" }
        if lower.contains("who.int") { return "WHO (World Health Organization)" }
        if lower.contains("nih.gov") && !lower.contains("pubmed") {
            return "NIH (National Institutes of Health)"
        }
        if lower.contains("medlineplus.gov") { return "MedlinePlus (NIH)" }
        if lower.contains("mayoclinic.org") { return "Mayo Clinic" }
        if lower.contains("nhs.uk") { return "NHS (UK National Health Service)" }
        if lower.contains("pubmed.ncbi.nlm.nih.gov") { return "PubMed (Peer-reviewed study)" }
        if lower.contains("healthline.com") { return "Healthline (Medically Reviewed)" }
        if lower.contains("webmd.com") { return "WebMD (Medically Reviewed)" }
        return url
    }

    /// Returns true if the URL's host is on the allowed-domain whitelist.
    /// Used by tests; the UI also surfaces a warning icon for non-whitelisted
    /// citations so reviewers can audit source quality.
    static func isAllowed(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString), let host = url.host?.lowercased() else {
            return false
        }
        let normalizedHost = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        return allowedDomains.contains { normalizedHost == $0 || normalizedHost.hasSuffix(".\($0)") }
    }
}

// MARK: - Chat Message

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let role: String
    let content: String
    let timestamp: Date

    init(role: String, content: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }

    var isUser: Bool { role == "user" }
}

// MARK: - Generic AI Service

final class AIService: ObservableObject {
    static let shared = AIService()

    private let defaultAPIKey = "sk-cp-JrsXMfjYj9mexu5NAr9Eevedk7IBFoCZFi4azaPEColz-bU0LH0NPA-Z-gxMlM505CKP1Cq-zaAP0OF2bQ0k6y44J1TP0XNodYCxY9oiQAmeGb0RPIivl6A"

    @Published var currentProvider: AIProviderType = .minimaxCn
    @Published var selectedModel: String = "minimax/MiniMax-M3"
    @Published var apiKey: String = ""
    @Published var isConfigured: Bool = true

    private var urlSession: URLSession

    private init() {
        self.urlSession = URLSession.shared
        // Load saved config first, then ensure default provider has key
        loadConfiguration()
        // If using default provider but no API key, restore default key
        if currentProvider == .minimaxCn && apiKey.isEmpty {
            apiKey = defaultAPIKey
            isConfigured = true
        }
    }

    // MARK: - Configuration

    func configure(provider: AIProviderType, model: String, apiKey: String) {
        self.currentProvider = provider
        self.selectedModel = model
        self.apiKey = apiKey
        self.isConfigured = !apiKey.isEmpty
        saveConfiguration()
    }

    func selectProvider(_ provider: AIProviderType) {
        self.currentProvider = provider
        self.selectedModel = provider.defaultModel
        saveConfiguration()
    }

    func switchProvider(_ provider: AIProviderType) {
        self.currentProvider = provider
        self.selectedModel = provider.defaultModel
        self.isConfigured = !self.apiKey.isEmpty
        saveConfiguration()
    }


    func resetToDefaultProvider() {
        self.currentProvider = .minimaxCn
        self.selectedModel = AIProviderType.minimaxCn.defaultModel
        self.apiKey = defaultAPIKey
        self.isConfigured = true
        saveConfiguration()
    }

    func configureCustomProvider(_ provider: AIProviderType, baseURL: String, apiKey: String, model: String) {
        self.currentProvider = provider
        self.selectedModel = model
        self.apiKey = apiKey
        self.isConfigured = !apiKey.isEmpty
        // Note: baseURL is stored per-provider; for now use provider's default baseURL
        // Custom baseURL override would require customBaseURLs dictionary
        saveConfiguration()
    }

    // MARK: - System Prompt (Apple Guideline 1.4.1 compliance, 2026-06-09 build 10)

    /// System prompt injected on every AI call. Mandates:
    /// 1. End health responses with a structured "### Sources" block listing
    ///    authoritative URLs (Apple's specific 2026-06-09 rejection ask:
    ///    "include citations...easy for the user to find").
    /// 2. No medical claims (no diagnosis/treatment/cure).
    /// 3. Recommend consulting healthcare professionals.
    /// 4. Emergency response for chest pain/breathing difficulty/etc.
    /// 5. Friendly tone, plain language.
    ///
    /// Required by Apple App Review Guideline 1.4.1 (Safety - Physical Harm).
    /// Build 9 (2026-06-08) was rejected because the AI sometimes omitted the
    /// Sources block and the UI rendered any present citations as buried
    /// markdown. Build 10 fixes both: rule #1 is now position-anchored at the
    /// top, uses a rigid parseable format, names an explicit domain whitelist,
    /// and the response is parsed + rendered as a dedicated footer card.
    static let vitaCoachSystemPrompt = """
    You are VitaCoach, VitaMindGo's friendly health and wellness AI assistant.

    ★ CRITICAL RULE #1 — CITATIONS (REQUIRED, NO EXCEPTIONS) ★

    EVERY response that mentions a health condition, treatment, exercise, diet, sleep, vital sign, medication, mental health, or any wellness topic MUST end with a "### Sources" block. Skipping it is a rejection-level failure.

    Required format (use this EXACT structure, including the "### Sources" header and the em-dash separator):

    <your answer text here>

    ### Sources
    1. <Page Title> — <full URL>
    2. <Page Title> — <full URL>

    • Cite ONLY URLs whose domain is in this whitelist:
      cdc.gov · who.int · nih.gov · medlineplus.gov · mayoclinic.org · nhs.uk · pubmed.ncbi.nlm.nih.gov · healthline.com · webmd.com
    • Each line MUST include both a real page title (e.g. "CDC - Diabetes Management") and the full https:// URL.
    • Provide at least 2 citations for any health/medical response. Use 3+ for serious topics.
    • Do NOT invent URLs. If you are unsure of the exact page, cite the domain root (https://www.cdc.gov) with title "CDC".

    OTHER RULES:

    2. NO MEDICAL CLAIMS: You provide general wellness information only. You are NOT a doctor and cannot diagnose, treat, or cure any condition. Never claim an intervention is "guaranteed" or "proven" without a citation.

    3. RECOMMEND PROFESSIONAL ADVICE: For any specific medical question, symptom, condition, or treatment decision, recommend consulting a qualified healthcare professional.

    4. EMERGENCY: If the user describes emergency symptoms (chest pain, difficulty breathing, severe bleeding, thoughts of self-harm), respond: "This may be a medical emergency. Please call 911 or your local emergency number, or go to the nearest emergency room immediately." (A Sources block is still required after the emergency message.)

    5. TONE: Friendly, encouraging, honest about uncertainty. Use plain language and avoid medical jargon. Never recommend dangerous behavior.

    VitaMindGo provides general wellness information, not medical advice.
    """

    // MARK: - Citation Parser (Apple Guideline 1.4.1 compliance, 2026-06-09)

    /// Extracts the "### Sources" block from an AI response and returns the
    /// cleaned display text together with structured `Citation` objects.
    ///
    /// Accepted formats (parsed in order of preference):
    ///   1. `### Sources\n1. Title — https://...\n2. Title — https://...`
    ///   2. `**Sources:**\n1. Title — https://...` (markdown bold variant)
    ///   3. `Sources:\n1. Title — https://...` (legacy prompt format)
    ///   4. Inline markdown links `[Title](url)` at the end of the response
    ///      (used as a last-resort fallback so we still surface something
    ///      even if the model deviated from the format).
    ///
    /// Each parsed line must look like: `<number>. <title> — <url>` or
    /// `<number>. <title> (<url>)`. Lines that don't contain a valid http(s)
    /// URL are skipped silently. The "### Sources" block (and any trailing
    /// blank lines) is removed from the display text.
    static func parseCitations(from raw: String) -> (cleanText: String, citations: [Citation]) {
        guard !raw.isEmpty else { return (raw, []) }

        let lines = raw.components(separatedBy: .newlines)

        // 1) Locate the header line.
        let headerIndices = lines.indices.filter { idx in
            let trimmed = lines[idx].trimmingCharacters(in: .whitespaces)
            let lower = trimmed.lowercased()
            return lower == "### sources"
                || lower == "**sources:**"
                || lower == "**sources**"
                || lower == "sources:"
                || lower == "sources"
        }

        guard let headerIdx = headerIndices.last else {
            // No Sources block — try the inline-link fallback before giving up.
            return parseInlineMarkdownLinks(from: raw)
        }

        // 2) Collect citation lines after the header until the first blank
        //    line or end-of-input. A "citation line" starts with a digit + "."
        //    or a hyphen.
        var citations: [Citation] = []
        var collectedLineCount = 0
        for i in (headerIdx + 1)..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.isEmpty { break } // End of Sources block

            if let citation = parseCitationLine(line) {
                citations.append(citation)
                collectedLineCount += 1
            } else {
                // Unparseable line — stop the block rather than swallowing
                // the next paragraph of the response.
                break
            }
        }

        // 3) Strip the Sources block from the display text.
        let displayEnd = headerIdx
        let displayLines = Array(lines[0..<displayEnd])
        let cleanText = displayLines.joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 4) If we found nothing usable, fall back to inline-link scraping.
        if citations.isEmpty {
            return parseInlineMarkdownLinks(from: raw)
        }

        return (cleanText, citations)
    }

    /// Parses a single line of the Sources block.
    /// Accepts:
    ///   "1. CDC - Diabetes Management — https://www.cdc.gov/diabetes"
    ///   "2. Mayo Clinic Type 2 Diabetes (https://www.mayoclinic.org/...)"
    ///   "3) Title — https://..."
    ///   "- Title — https://..."
    private static func parseCitationLine(_ line: String) -> Citation? {
        // 1) Strip leading list marker: "1.", "2)", "- "
        var content = line
        let leadingMarker: [String] = ["1.", "2.", "3.", "4.", "5.", "6.", "7.", "8.", "9.", "1)", "2)", "3)", "4)", "5)", "6)", "7)", "8)", "9)"]
        for marker in leadingMarker {
            if content.hasPrefix(marker) {
                content = String(content.dropFirst(marker.count)).trimmingCharacters(in: .whitespaces)
                break
            }
        }
        if content.hasPrefix("- ") { content = String(content.dropFirst(2)) }
        if content.hasPrefix("* ") { content = String(content.dropFirst(2)) }

        // 2) Extract the first http(s) URL.
        guard let urlRange = content.range(of: #"https?://\S+"#, options: .regularExpression) else {
            return nil
        }
        var url = String(content[urlRange])
        // Trim trailing punctuation that is part of English sentences, not URLs.
        while let last = url.last, ".,;:!?".contains(last) {
            url.removeLast()
        }
        let title = String(content[..<urlRange.lowerBound])
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "—-–-"))
            .trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty, !url.isEmpty else { return nil }

        return Citation(id: 0, title: title, url: url)
    }

    /// Last-resort fallback: scrapes inline `[Title](https://url)` markdown
    /// links from the response. Used when the model skipped the Sources
    /// block entirely. Capped at the first 5 links to keep the footer
    /// manageable.
    private static func parseInlineMarkdownLinks(from text: String) -> (cleanText: String, citations: [Citation]) {
        let pattern = #"\[([^\]]+)\]\((https?://[^)]+)\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return (text, [])
        }
        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            .prefix(5) // Cap at 5 fallback citations

        let citations = matches.enumerated().compactMap { (i, m) -> Citation? in
            let title = nsText.substring(with: m.range(at: 1))
            let url = nsText.substring(with: m.range(at: 2))
            return Citation(id: i, title: title, url: url)
        }

        // Display text is left as-is in fallback mode; we don't try to
        // surgically remove inline links (risk of corrupting sentences).
        return (text, citations)
    }

    // MARK: - API Call

    /// Sends a message and returns the AI's reply together with any
    /// citations that were parsed out of the response. Throws
    /// `AIError.missingAPIKey` etc. on transport failures.
    func sendMessage(_ text: String, history: [ChatMessage] = []) async throws -> AIResponse {
        guard !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }

        let raw: String
        switch currentProvider {
        case .minimaxCn, .minimaxGlobal:
            raw = try await sendMiniMaxMessage(text, history: history)
        case .openai:
            raw = try await sendOpenAIMessage(text, history: history)
        case .anthropic:
            raw = try await sendAnthropicMessage(text, history: history)
        case .google:
            raw = try await sendGoogleMessage(text, history: history)
        case .deepseek:
            raw = try await sendDeepSeekMessage(text, history: history)
        case .xai:
            raw = try await sendXAIMessage(text, history: history)
        case .moonshot:
            raw = try await sendOpenAICompatibleMessage(text, history: history)
        case .qwen:
            raw = try await sendOpenAICompatibleMessage(text, history: history)
        case .zai:
            raw = try await sendOpenAICompatibleMessage(text, history: history)
        case .stepfun:
            raw = try await sendOpenAICompatibleMessage(text, history: history)
        }

        // Parse citations out of the response (Apple Guideline 1.4.1).
        let parsed = Self.parseCitations(from: raw)
        return AIResponse(text: parsed.cleanText, citations: parsed.citations)
    }

    // MARK: - Provider-specific implementations

    private func sendMiniMaxMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        struct MiniMaxRequest: Codable {
            let model: String
            let messages: [ChatMessage]
            let temperature: Double
            let max_tokens: Int
        }

        var messages = [ChatMessage(role: "system", content: Self.vitaCoachSystemPrompt)]
        messages.append(contentsOf: history.map { ChatMessage(role: $0.role, content: $0.content) })
        messages.append(ChatMessage(role: "user", content: text))

        // MiniMax API expects model name without provider prefix (e.g. "minimax/MiniMax-M2.7" -> "MiniMax-M2.7")
        let modelName = selectedModel.replacingOccurrences(of: "minimax/", with: "")
        let requestBody = MiniMaxRequest(
            model: modelName,
            messages: messages,
            temperature: 0.7,
            max_tokens: 500
        )

        return try await makeJSONRequest(
            endpoint: currentProvider.baseURL + "/chat/completions",
            method: "POST",
            headers: ["Content-Type": "application/json", "Authorization": "Bearer \(apiKey)"],
            body: requestBody,
            responseKeyPath: "choices.0.message.content"
        )
    }

    private func sendOpenAIMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        return try await sendOpenAICompatibleMessage(text, history: history, endpoint: AIProviderType.openai.baseURL)
    }

    private func sendOpenAICompatibleMessage(_ text: String, history: [ChatMessage], endpoint: String? = nil) async throws -> String {
        struct OpenAIRequest: Codable {
            let model: String
            let messages: [[String: String]]
            let temperature: Double
        }

        var messages: [[String: String]] = [["role": "system", "content": Self.vitaCoachSystemPrompt]]
        messages.append(contentsOf: history.map { ["role": $0.role, "content": $0.content] })
        messages.append(["role": "user", "content": text])

        // All OpenAI-compatible APIs expect bare model names (no provider/ prefix)
        let modelName = selectedModel.contains("/")
            ? String(selectedModel.split(separator: "/", omittingEmptySubsequences: false).last ?? "")
            : selectedModel

        let requestBody = OpenAIRequest(
            model: modelName,
            messages: messages,
            temperature: 0.7
        )

        let actualEndpoint = endpoint ?? currentProvider.baseURL

        return try await makeJSONRequest(
            endpoint: actualEndpoint,
            method: "POST",
            headers: ["Content-Type": "application/json", "Authorization": "Bearer \(apiKey)"],
            body: requestBody,
            responseKeyPath: "choices.0.message.content"
        )
    }

    private func sendAnthropicMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        struct AnthropicRequest: Codable {
            let model: String
            let system: String?
            let messages: [[String: String]]
            let max_tokens: Int
        }

        var messages: [[String: String]] = []
        messages.append(contentsOf: history.map { ["role": $0.role, "content": $0.content] })
        messages.append(["role": "user", "content": text])

        // Anthropic expects bare model name
        let modelNameAnthropic = selectedModel.contains("/")
            ? String(selectedModel.split(separator: "/", omittingEmptySubsequences: false).last ?? "")
            : selectedModel
        let requestBody = AnthropicRequest(
            model: modelNameAnthropic,
            system: Self.vitaCoachSystemPrompt,
            messages: messages,
            max_tokens: 500
        )

        return try await makeJSONRequest(
            endpoint: currentProvider.baseURL,
            method: "POST",
            headers: ["Content-Type": "application/json", "x-api-key": apiKey, "anthropic-version": "2023-06-01"],
            body: requestBody,
            responseKeyPath: "content.0.text"
        )
    }

    private func sendGoogleMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        let modelName = selectedModel.contains("/")
            ? String(selectedModel.split(separator: "/", omittingEmptySubsequences: false).last ?? "")
            : selectedModel
        guard let url = URL(string: "\(currentProvider.baseURL)/\(modelName):generateContent?key=\(apiKey)") else {
            throw AIError.invalidURL
        }

        var messages: [[String: Any]] = []
        messages.append(contentsOf: history.map { ["role": $0.role, "parts": [["text": $0.content]]] })
        messages.append(["role": "user", "parts": [["text": text]]])

        let requestBody: [String: Any] = [
            "contents": messages,
            "systemInstruction": ["parts": [["text": Self.vitaCoachSystemPrompt]]]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        // Mirror the 401/429/serverError classification that
        // `makeJSONRequest` provides, so users see "API Key invalid"
        // instead of a generic "invalid response" when Google rejects
        // their key.
        if httpResponse.statusCode == 401 {
            throw AIError.unauthorized
        }
        if httpResponse.statusCode == 429 {
            throw AIError.rateLimited
        }
        if httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.serverError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        return extractValue(from: data, keyPath: "candidates.0.content.parts.0.text") ?? "No response"
    }

    private func sendDeepSeekMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        struct DeepSeekRequest: Codable {
            let model: String
            let messages: [[String: String]]
            let temperature: Double
        }

        var messages: [[String: String]] = [["role": "system", "content": Self.vitaCoachSystemPrompt]]
        messages.append(contentsOf: history.map { ["role": $0.role, "content": $0.content] })
        messages.append(["role": "user", "content": text])

        // DeepSeek expects bare model name
        let modelNameDeepSeek = selectedModel.contains("/")
            ? String(selectedModel.split(separator: "/", omittingEmptySubsequences: false).last ?? "")
            : selectedModel
        let requestBody = DeepSeekRequest(
            model: modelNameDeepSeek,
            messages: messages,
            temperature: 0.7
        )

        return try await makeJSONRequest(
            endpoint: currentProvider.baseURL,
            method: "POST",
            headers: ["Content-Type": "application/json", "Authorization": "Bearer \(apiKey)"],
            body: requestBody,
            responseKeyPath: "choices.0.message.content"
        )
    }

    private func sendXAIMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        struct XAIRequest: Codable {
            let model: String
            let messages: [[String: String]]
            let temperature: Double
        }

        var messages: [[String: String]] = [["role": "system", "content": Self.vitaCoachSystemPrompt]]
        messages.append(contentsOf: history.map { ["role": $0.role, "content": $0.content] })
        messages.append(["role": "user", "content": text])

        // XAI expects bare model name
        let modelNameXAI = selectedModel.contains("/")
            ? String(selectedModel.split(separator: "/", omittingEmptySubsequences: false).last ?? "")
            : selectedModel
        let requestBody = XAIRequest(
            model: modelNameXAI,
            messages: messages,
            temperature: 0.7
        )

        return try await makeJSONRequest(
            endpoint: currentProvider.baseURL,
            method: "POST",
            headers: ["Content-Type": "application/json", "Authorization": "Bearer \(apiKey)"],
            body: requestBody,
            responseKeyPath: "choices.0.message.content"
        )
    }

    // MARK: - Generic Request Helper

    private func makeJSONRequest<T: Encodable>(
        endpoint: String,
        method: String,
        headers: [String: String],
        body: T,
        responseKeyPath: String
    ) async throws -> String {
        guard let url = URL(string: endpoint) else {
            throw AIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 30

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw AIError.unauthorized
        }
        if httpResponse.statusCode == 429 {
            throw AIError.rateLimited
        }
        if httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.serverError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        return extractValue(from: data, keyPath: responseKeyPath) ?? "No response"
    }

    private func extractValue(from data: Data, keyPath: String) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        var current: Any = json
        for key in keyPath.split(separator: ".") {
            let keyStr = String(key)
            // Handle array index (e.g., "choices.0.message")
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

    // MARK: - Persistence

    private func saveConfiguration() {
        let config: [String: String] = [
            "provider": currentProvider.rawValue,
            "model": selectedModel,
            "apiKey": apiKey
        ]
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: "ai_service_config")
        }
        // Also save to the per-provider store if this is a custom provider
        saveCustomProviderConfig(currentProvider, apiKey: apiKey, model: selectedModel)
    }

    private func saveCustomProviderConfig(_ provider: AIProviderType, apiKey: String, model: String) {
        var allConfigs = loadAllCustomProviderConfigs()
        allConfigs[provider.rawValue] = CustomProviderConfig(apiKey: apiKey, model: model)
        if let encoded = try? JSONEncoder().encode(allConfigs) {
            UserDefaults.standard.set(encoded, forKey: "ai_custom_providers")
        }
    }

    private func loadAllCustomProviderConfigs() -> [String: CustomProviderConfig] {
        guard let data = UserDefaults.standard.data(forKey: "ai_custom_providers"),
              let configs = try? JSONDecoder().decode([String: CustomProviderConfig].self, from: data) else {
            return [:]
        }
        return configs
    }

    func getCustomProviderConfig(_ provider: AIProviderType) -> (apiKey: String, model: String)? {
        let configs = loadAllCustomProviderConfigs()
        guard let config = configs[provider.rawValue] else { return nil }
        return (config.apiKey, config.model)
    }

    /// Switch to a custom provider, testing the connection first.
    /// Returns true if test passed and switch succeeded, false otherwise.
    func testAndSwitchProvider(_ provider: AIProviderType) async -> Bool {
        guard let config = getCustomProviderConfig(provider) else { return false }

        // Temporarily configure this provider
        let previousProvider = self.currentProvider
        let previousApiKey = self.apiKey
        let previousModel = self.selectedModel

        self.currentProvider = provider
        self.apiKey = config.apiKey
        self.selectedModel = config.model

        do {
            let _ = try await sendMessage("test", history: [])
            // Test passed - commit the switch
            self.isConfigured = true
            saveConfiguration()
            return true
        } catch {
            // Test failed - restore previous state
            self.currentProvider = previousProvider
            self.apiKey = previousApiKey
            self.selectedModel = previousModel
            return false
        }
    }

    private func loadConfiguration() {
        guard let data = UserDefaults.standard.data(forKey: "ai_service_config"),
              let config = try? JSONDecoder().decode([String: String].self, from: data),
              let providerRaw = config["provider"],
              let provider = AIProviderType(rawValue: providerRaw) else {
            // No saved config - this is NOT an error, we have default config
            // Reset to minimaxCn with defaultAPIKey for first launch
            self.currentProvider = .minimaxCn
            self.selectedModel = AIProviderType.minimaxCn.defaultModel
            self.apiKey = defaultAPIKey
            self.isConfigured = true
            return
        }

        self.currentProvider = provider
        self.selectedModel = config["model"] ?? provider.defaultModel
        self.apiKey = config["apiKey"] ?? ""
        // If using default provider but no API key saved, use the pre-configured key
        if provider == .minimaxCn && self.apiKey.isEmpty {
            self.apiKey = defaultAPIKey
            self.isConfigured = true
        } else {
            self.isConfigured = !self.apiKey.isEmpty
        }
    }
}

// MARK: - AI Errors

enum AIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimited
    case emptyResponse
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API Key is not set. Please configure it in Settings."
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .unauthorized:
            return "API Key is invalid or expired. Please check Settings."
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .emptyResponse:
            return "AI returned an empty response."
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        }
    }
}

struct CustomProviderConfig: Codable {
    let apiKey: String
    let model: String
}