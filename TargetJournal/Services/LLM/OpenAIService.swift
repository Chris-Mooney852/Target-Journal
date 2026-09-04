import Foundation

/// OpenAI API client conforming to LLMService.
public final class OpenAIService: LLMService, @unchecked Sendable {
    public let providerId: String = "openai"
    public let providerName: String = "OpenAI"
    
    private let apiKeyProvider: @Sendable () -> String?
    private let baseURLString: String
    private let modelName: String
    private let urlSession: URLSession
    
    public init(
        baseURLString: String = "https://api.openai.com/v1/chat/completions",
        modelName: String = "gpt-4o",
        urlSession: URLSession = .shared,
        apiKeyProvider: @escaping @Sendable () -> String? = { KeychainHelper.shared.getKey(for: .openAI) }
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
        
        var requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "response_format": ["type": "json_object"]
        ]
        
        // Reasoning models (o1, o3-mini) do not accept custom temperature
        let isReasoningModel = modelName.hasPrefix("o1") || modelName.hasPrefix("o3")
        if !isReasoningModel {
            requestBody["temperature"] = 0.3
        }
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw LLMError.invalidRequest("Failed to serialize OpenAI payload")
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
            let errorMsg = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
            throw LLMError.invalidResponse(statusCode: httpResponse.statusCode, message: errorMsg)
        }
        
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
        
        let isReasoningModel = modelName.hasPrefix("o1") || modelName.hasPrefix("o3")
        var requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": "You are a test assistant. Reply with JSON {\"status\":\"ok\"}"],
                ["role": "user", "content": "ping"]
            ],
            "response_format": ["type": "json_object"]
        ]
        
        if isReasoningModel {
            requestBody["max_completion_tokens"] = 25
        } else {
            requestBody["max_tokens"] = 25
            requestBody["temperature"] = 0.0
        }
        
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
}
