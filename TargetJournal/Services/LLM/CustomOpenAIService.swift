import Foundation

/// Generic OpenAI-compatible client for custom endpoints, Ollama, LM Studio, Groq, etc.
public final class CustomOpenAIService: LLMService, @unchecked Sendable {
    public let providerId: String = "custom_openai"
    public let providerName: String = "Custom / Ollama"
    
    private let apiKeyProvider: @Sendable () -> String?
    private let baseURLString: String
    private let modelName: String
    private let urlSession: URLSession
    
    public init(
        baseURLString: String = "http://localhost:11434/v1/chat/completions",
        modelName: String = "qwen2.5:latest",
        urlSession: URLSession = .shared,
        apiKeyProvider: @escaping @Sendable () -> String? = { KeychainHelper.shared.getKey(for: .customOpenAI) }
    ) {
        self.baseURLString = baseURLString
        self.modelName = modelName
        self.urlSession = urlSession
        self.apiKeyProvider = apiKeyProvider
    }
    
    public func analyze(request: AnalysisRequest) async throws -> LLMAnalysisResponse {
        guard let url = URL(string: baseURLString) else {
            throw LLMError.invalidURL
        }
        
        let systemPrompt = PromptBuilder.buildSystemPrompt(for: request)
        let userPrompt = PromptBuilder.buildUserPrompt(for: request) + "\n\nCRITICAL: Respond ONLY with valid, raw JSON matching the required schema. Do not include markdown codeblocks."
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "response_format": ["type": "json_object"],
            "temperature": 0.3
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw LLMError.invalidRequest("Failed to serialize custom LLM payload")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let apiKey = apiKeyProvider()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !apiKey.isEmpty {
            urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = httpBody
        urlRequest.timeoutInterval = 90
        
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
        guard let url = URL(string: baseURLString) else {
            throw LLMError.invalidURL
        }
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": "You are a test helper. Reply with JSON {\"status\":\"ok\"}"],
                ["role": "user", "content": "ping"]
            ],
            "max_tokens": 20
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let apiKey = apiKeyProvider()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !apiKey.isEmpty {
            urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        urlRequest.timeoutInterval = 15
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Connection failed"
            throw LLMError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: msg)
        }
        return true
    }
}
