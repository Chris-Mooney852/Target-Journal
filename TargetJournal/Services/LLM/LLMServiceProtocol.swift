import Foundation

/// Protocol that all LLM providers (DeepSeek, OpenAI, Claude, Apple Intelligence) must conform to.
public protocol LLMService: Sendable {
    var providerId: String { get }
    var providerName: String { get }
    
    /// Analyzes a journal entry based on the user's proficiency level.
    func analyze(request: AnalysisRequest) async throws -> LLMAnalysisResponse
    
    /// Tests connectivity with the configured API key and endpoint.
    func testConnection() async throws -> Bool
}
