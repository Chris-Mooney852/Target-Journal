import Foundation

/// DeepSeek API client implementation conforming to LLMService.
public final class DeepSeekService: LLMService, @unchecked Sendable {
    public let providerId: String = "deepseek"
    public let providerName: String = "DeepSeek"
    
    private let apiKeyProvider: @Sendable () -> String?
    private let baseURLString: String
    private let modelName: String
    private let urlSession: URLSession
    
    public init(
        baseURLString: String = "https://api.deepseek.com/chat/completions",
        modelName: String = "deepseek-chat",
        urlSession: URLSession = .shared,
        apiKeyProvider: @escaping @Sendable () -> String? = { KeychainHelper.shared.getDeepSeekKey() }
    ) {
        self.baseURLString = baseURLString
        self.modelName = modelName
        self.urlSession = urlSession
        self.apiKeyProvider = apiKeyProvider
    }
    
    public func analyze(request: AnalysisRequest) async throws -> LLMAnalysisResponse {
        guard let apiKey = apiKeyProvider(), !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LLMError.missingApiKey(provider: providerName)
        }
        
        guard let url = URL(string: baseURLString) else {
            throw LLMError.invalidURL
        }
        
        let systemPrompt = PromptBuilder.buildSystemPrompt(for: request)
        let userPrompt = PromptBuilder.buildUserPrompt(for: request)
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "response_format": ["type": "json_object"],
            "temperature": 0.4,
            "stream": false
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw LLMError.invalidRequest("Failed to serialize DeepSeek payload")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = httpBody
        urlRequest.timeoutInterval = 60
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: urlRequest)
        } catch {
            throw LLMError.networkError(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.networkError("Invalid HTTP response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw LLMError.invalidResponse(statusCode: httpResponse.statusCode, message: errorMsg)
        }
        
        // Parse OpenAI-compatible chat completion envelope
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let contentString = message["content"] as? String else {
            throw LLMError.emptyResponse
        }
        
        return try JSONSanitizer.decodeAnalysisResponse(from: contentString)
    }
    
    public func testConnection() async throws -> Bool {
        guard let apiKey = apiKeyProvider(), !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LLMError.missingApiKey(provider: providerName)
        }
        
        guard let url = URL(string: baseURLString) else {
            throw LLMError.invalidURL
        }
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": "You are a test helper. Reply with JSON {\"status\":\"ok\"}"],
                ["role": "user", "content": "ping"]
            ],
            "response_format": ["type": "json_object"],
            "max_tokens": 20
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        urlRequest.timeoutInterval = 15
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Authentication failed"
            throw LLMError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: msg)
        }
        return true
    }
    
    public var supportsBalanceCheck: Bool { true }
    
    public func fetchBalance() async throws -> LLMBalanceInfo? {
        guard let apiKey = apiKeyProvider(), !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LLMError.missingApiKey(provider: providerName)
        }
        
        guard let url = URL(string: "https://api.deepseek.com/user/balance") else {
            throw LLMError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15
        
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Failed to fetch balance"
            throw LLMError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: msg)
        }
        
        struct DeepSeekBalanceResponse: Decodable {
            let is_available: Bool?
            let balance_infos: [BalanceItem]
            
            struct BalanceItem: Decodable {
                let currency: String
                let total_balance: String
                let granted_balance: String?
                let topped_up_balance: String?
            }
        }
        
        let decoded = try JSONDecoder().decode(DeepSeekBalanceResponse.self, from: data)
        let isAvail = decoded.is_available ?? true
        
        let activeItem = decoded.balance_infos.first { (Double($0.total_balance) ?? 0) > 0 } ?? decoded.balance_infos.first
        guard let item = activeItem else { return nil }
        
        return LLMBalanceInfo(
            currency: item.currency,
            totalBalance: item.total_balance,
            grantedBalance: item.granted_balance,
            toppedUpBalance: item.topped_up_balance,
            isAvailable: isAvail
        )
    }
}
