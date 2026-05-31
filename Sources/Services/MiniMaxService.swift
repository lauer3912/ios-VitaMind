import Foundation

final class MiniMaxService: ObservableObject {
    static let shared = MiniMaxService()
    
    @Published var isLoading = false
    @Published var lastError: String?
    
    private let apiKey: String
    private let baseURL = "https://api.minimax.chat/v1"
    private let modelName = "MiniMax-M2"
    
    private init() {
        // 从环境变量或配置读取 API Key
        self.apiKey = ProcessInfo.processInfo.environment["MINIMAX_API_KEY"] ?? ""
    }
    
    struct ChatMessage: Codable {
        let role: String
        let content: String
    }
    
    struct ChatRequest: Codable {
        let model: String
        let messages: [ChatMessage]
        let temperature: Double
        let max_tokens: Int
    }
    
    struct ChatResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
            
            struct Message: Codable {
                let content: String
            }
        }
    }
    
    func sendMessage(_ text: String, history: [ChatMessage] = []) async throws -> String {
        guard !apiKey.isEmpty else {
            throw MiniMaxError.missingAPIKey
        }
        
        await MainActor.run {
            self.isLoading = true
            self.lastError = nil
        }
        
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }
        
        var messages = history
        messages.append(ChatMessage(role: "user", content: text))
        
        let requestBody = ChatRequest(
            model: modelName,
            messages: messages,
            temperature: 0.7,
            max_tokens: 500
        )
        
        guard let url = URL(string: "\(baseURL)/text/chatcompletion_v2") else {
            throw MiniMaxError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    throw MiniMaxError.unauthorized
                }
                if httpResponse.statusCode == 429 {
                    throw MiniMaxError.rateLimited
                }
                if httpResponse.statusCode != 200 {
                    let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw MiniMaxError.serverError(statusCode: httpResponse.statusCode, message: errorBody)
                }
            }
            
            let decoder = JSONDecoder()
            let chatResponse = try decoder.decode(ChatResponse.self, from: data)
            
            guard let responseText = chatResponse.choices.first?.message.content else {
                throw MiniMaxError.emptyResponse
            }
            
            return responseText
            
        } catch let error as MiniMaxError {
            await MainActor.run {
                self.lastError = error.localizedDescription
            }
            throw error
        } catch {
            await MainActor.run {
                self.lastError = error.localizedDescription
            }
            throw MiniMaxError.networkError(error)
        }
    }
    
    // Generate health advice based on user data
    func generateHealthAdvice(steps: Double, heartRate: Double, sleep: Double, water: Double) async throws -> String {
        let prompt = """
        You are VitaCoach, a friendly and knowledgeable health AI assistant. Based on the user's today's health data:
        - Steps: \(Int(steps))
        - Heart Rate: \(Int(heartRate)) BPM
        - Sleep: \(String(format: "%.1f", sleep)) hours
        - Water: \(Int(water)) glasses
        
        Provide 2-3 short, actionable health tips. Be encouraging and friendly. Keep it under 100 words total.
        """
        
        return try await sendMessage(prompt)
    }
}

enum MiniMaxError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case unauthorized
    case rateLimited
    case serverError(statusCode: Int, message: String)
    case emptyResponse
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "MiniMax API key is not configured. Please set MINIMAX_API_KEY environment variable."
        case .invalidURL:
            return "Invalid API URL"
        case .unauthorized:
            return "Invalid API key or unauthorized access"
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .emptyResponse:
            return "Empty response from API"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}