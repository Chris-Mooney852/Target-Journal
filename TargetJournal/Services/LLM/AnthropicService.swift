import Foundation

/// Anthropic Claude API client conforming to LLMService.
public final class AnthropicService: LLMService, @unchecked Sendable {
    public let providerId: String = "anthropic"
    public let providerName: String = "Anthropic"
    
    private let apiKeyProvider: @Sendable () -> String?
    private let baseURLString: String
    private let modelName: String
    private let urlSession: URLSession
    
    public init(
        baseURLString: String = "https://api.anthropic.com/v1/messages",
        modelName: String = "claude-3-7-sonnet-20250219",
        urlSession: URLSession = .shared,
        apiKeyProvider: @escaping @Sendable () -> String? = { KeychainHelper.shared.getKey(for: .anthropic) }
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
        let userPrompt = PromptBuilder.buildUserPrompt(for: request) + "\n\nCRITICAL: Respond ONLY with valid, raw JSON matching the required schema. Do not include markdown codeblocks or extraneous commentary."
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "max_tokens": 4096,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.3
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw LLMError.invalidRequest("Failed to serialize Anthropic payload")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
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
              let contents = json["content"] as? [[String: Any]],
              let firstBlock = contents.first(where: { ($0["type"] as? String) == "text" }),
              let textContent = firstBlock["text"] as? String else {
            throw LLMError.emptyResponse
        }
        
        return try JSONSanitizer.decodeAnalysisResponse(from: textContent)
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
            "max_tokens": 20,
            "messages": [
                ["role": "user", "content": "Ping. Reply with {\"status\":\"ok\"} in JSON format."]
            ]
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
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
