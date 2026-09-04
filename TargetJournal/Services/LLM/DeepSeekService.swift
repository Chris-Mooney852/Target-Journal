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
            throw LLMError.missingApiKey
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
            throw LLMError.invalidRequest
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
        
        // Extract raw JSON string, stripping any accidental markdown code fences
        let cleanedJSON = sanitizeJSONContent(contentString)
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw LLMError.decodingError("Could not convert content to UTF-8 data")
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(LLMAnalysisResponse.self, from: jsonData)
            return decoded
        } catch {
            throw LLMError.decodingError("JSON decoding error: \(error.localizedDescription)\nContent: \(cleanedJSON)")
        }
    }
    
    public func testConnection() async throws -> Bool {
        guard let apiKey = apiKeyProvider(), !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LLMError.missingApiKey
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
    
    private func sanitizeJSONContent(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```json") {
            text = String(text.dropFirst(7))
        } else if text.hasPrefix("```") {
            text = String(text.dropFirst(3))
        }
        if text.hasSuffix("```") {
            text = String(text.dropLast(3))
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
