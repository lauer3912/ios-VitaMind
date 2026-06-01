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
    
    // MARK: - API Call
    
    func sendMessage(_ text: String, history: [ChatMessage] = []) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }
        
        switch currentProvider {
        case .minimaxCn, .minimaxGlobal:
            return try await sendMiniMaxMessage(text, history: history)
        case .openai:
            return try await sendOpenAIMessage(text, history: history)
        case .anthropic:
            return try await sendAnthropicMessage(text, history: history)
        case .google:
            return try await sendGoogleMessage(text, history: history)
        case .deepseek:
            return try await sendDeepSeekMessage(text, history: history)
        case .xai:
            return try await sendXAIMessage(text, history: history)
        case .moonshot:
            return try await sendOpenAICompatibleMessage(text, history: history)
        case .qwen:
            return try await sendOpenAICompatibleMessage(text, history: history)
        case .zai:
            return try await sendOpenAICompatibleMessage(text, history: history)
        case .stepfun:
            return try await sendOpenAICompatibleMessage(text, history: history)
        }
    }
    
    // MARK: - Provider-specific implementations
    
    private func sendMiniMaxMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        struct MiniMaxRequest: Codable {
            let model: String
            let messages: [ChatMessage]
            let temperature: Double
            let max_tokens: Int
        }
        
        var messages = history.map { ChatMessage(role: $0.role, content: $0.content) }
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
            endpoint: AIProviderType.minimaxCn.baseURL,
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
        
        var messages = history.map { ["role": $0.role, "content": $0.content] }
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
            let messages: [[String: String]]
            let max_tokens: Int
        }
        
        var messages = history.map { ["role": $0.role, "content": $0.content] }
        messages.append(["role": "user", "content": text])
        
        // Anthropic expects bare model name
        let modelNameAnthropic = selectedModel.contains("/") 
            ? String(selectedModel.split(separator: "/", omittingEmptySubsequences: false).last ?? "")
            : selectedModel
        let requestBody = AnthropicRequest(
            model: modelNameAnthropic,
            messages: messages,
            max_tokens: 500
        )
        
        return try await makeJSONRequest(
            endpoint: AIProviderType.anthropic.baseURL,
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
        guard let url = URL(string: "\(AIProviderType.google.baseURL)/\(modelName):generateContent?key=\(apiKey)") else {
            throw AIError.invalidURL
        }
        
        var messages = history.map { ["role": $0.role, "parts": [["text": $0.content]]] }
        messages.append(["role": "user", "parts": [["text": text]]])
        
        let requestBody: [String: Any] = ["contents": messages]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }
        
        return extractValue(from: data, keyPath: "candidates.0.content.parts.0.text") ?? "No response"
    }
    
    private func sendDeepSeekMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        struct DeepSeekRequest: Codable {
            let model: String
            let messages: [[String: String]]
            let temperature: Double
        }
        
        var messages = history.map { ["role": $0.role, "content": $0.content] }
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
            endpoint: AIProviderType.deepseek.baseURL,
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
        
        var messages = history.map { ["role": $0.role, "content": $0.content] }
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
            endpoint: AIProviderType.xai.baseURL,
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
            guard let dict = current as? [String: Any],
                  let value = dict[String(key)] else {
                return nil
            }
            current = value
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
            return "API Key 未设置，请在设置中配置"
        case .invalidURL:
            return "无效的 API 地址"
        case .invalidResponse:
            return "服务器响应无效"
        case .unauthorized:
            return "API Key 无效或已过期"
        case .rateLimited:
            return "请求过于频繁，请稍后重试"
        case .emptyResponse:
            return "AI 返回了空响应"
        case .serverError(let code, let message):
            return "服务器错误 (\(code)): \(message)"
        }
    }
}