import Foundation

// MARK: - AI Provider Configuration

enum AIProviderType: String, CaseIterable, Codable, Identifiable {
    case minimax = "MiniMax"
    case openai = "OpenAI"
    case anthropic = "Anthropic"
    case google = "Google"
    case deepseek = "DeepSeek"
    case xai = "xAI"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var iconName: String {
        switch self {
        case .minimax: return "brain"
        case .openai: return "sparkles"
        case .anthropic: return "person.fill"
        case .google: return "g.circle"
        case .deepseek: return "magnifyingglass"
        case .xai: return "x.circle"
        }
    }
    
    var defaultModel: String {
        switch self {
        case .minimax: return "MiniMax-M2.7"
        case .openai: return "gpt-4o"
        case .anthropic: return "claude-3-5-sonnet-20240620"
        case .google: return "gemini-1.5-pro"
        case .deepseek: return "deepseek-chat"
        case .xai: return "grok-2"
        }
    }
    
    var apiEndpoint: String {
        switch self {
        case .minimax: return "https://api.minimax.chat/v1/text/chatcompletion_v2"
        case .openai: return "https://api.openai.com/v1/chat/completions"
        case .anthropic: return "https://api.anthropic.com/v1/messages"
        case .google: return "https://generativelanguage.googleapis.com/v1beta/models"
        case .deepseek: return "https://api.deepseek.com/v1/chat/completions"
        case .xai: return "https://api.x.ai/v1/chat/completions"
        }
    }
    
    var supportedModels: [String] {
        switch self {
        case .minimax:
            return ["MiniMax-M2.7", "MiniMax-M2", "abab6.5s-chat", "abab6.5-chat"]
        case .openai:
            return ["gpt-4o", "gpt-4-turbo", "gpt-4", "gpt-3.5-turbo"]
        case .anthropic:
            return ["claude-3-5-sonnet-20240620", "claude-3-opus-20240229", "claude-3-sonnet-20240229"]
        case .google:
            return ["gemini-1.5-pro", "gemini-1.5-flash", "gemini-1.0-pro"]
        case .deepseek:
            return ["deepseek-chat", "deepseek-coder"]
        case .xai:
            return ["grok-2", "grok-1"]
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
    
    @Published var currentProvider: AIProviderType = .minimax
    @Published var selectedModel: String = "MiniMax-M2.7"
    @Published var apiKey: String = ""
    @Published var isConfigured: Bool = false
    
    private var urlSession: URLSession
    
    private init() {
        self.urlSession = URLSession.shared
        loadConfiguration()
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
    
    // MARK: - API Call
    
    func sendMessage(_ text: String, history: [ChatMessage] = []) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }
        
        switch currentProvider {
        case .minimax:
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
        
        let requestBody = MiniMaxRequest(
            model: selectedModel,
            messages: messages,
            temperature: 0.7,
            max_tokens: 500
        )
        
        return try await makeJSONRequest(
            endpoint: AIProviderType.minimax.apiEndpoint,
            method: "POST",
            headers: ["Content-Type": "application/json", "Authorization": "Bearer \(apiKey)"],
            body: requestBody,
            responseKeyPath: "choices.0.message.content"
        )
    }
    
    private func sendOpenAIMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        struct OpenAIRequest: Codable {
            let model: String
            let messages: [[String: String]]
            let temperature: Double
        }
        
        var messages = history.map { ["role": $0.role, "content": $0.content] }
        messages.append(["role": "user", "content": text])
        
        let requestBody = OpenAIRequest(
            model: selectedModel,
            messages: messages,
            temperature: 0.7
        )
        
        return try await makeJSONRequest(
            endpoint: AIProviderType.openai.apiEndpoint,
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
        
        let requestBody = AnthropicRequest(
            model: selectedModel,
            messages: messages,
            max_tokens: 500
        )
        
        return try await makeJSONRequest(
            endpoint: AIProviderType.anthropic.apiEndpoint,
            method: "POST",
            headers: ["Content-Type": "application/json", "x-api-key": apiKey, "anthropic-version": "2023-06-01"],
            body: requestBody,
            responseKeyPath: "content.0.text"
        )
    }
    
    private func sendGoogleMessage(_ text: String, history: [ChatMessage]) async throws -> String {
        guard let url = URL(string: "\(AIProviderType.google.apiEndpoint)/\(selectedModel):generateContent?key=\(apiKey)") else {
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
        
        let requestBody = DeepSeekRequest(
            model: selectedModel,
            messages: messages,
            temperature: 0.7
        )
        
        return try await makeJSONRequest(
            endpoint: AIProviderType.deepseek.apiEndpoint,
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
        
        let requestBody = XAIRequest(
            model: selectedModel,
            messages: messages,
            temperature: 0.7
        )
        
        return try await makeJSONRequest(
            endpoint: AIProviderType.xai.apiEndpoint,
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
            return
        }
        
        self.currentProvider = provider
        self.selectedModel = config["model"] ?? provider.defaultModel
        self.apiKey = config["apiKey"] ?? ""
        self.isConfigured = !self.apiKey.isEmpty
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