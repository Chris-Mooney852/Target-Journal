import Foundation

/// Central registry and coordinator for all LLM services.
public final class LLMServiceRegistry: Sendable {
    public static let shared = LLMServiceRegistry()
    
    private init() {}
    
    public func service(for profile: UserProfile) -> LLMService {
        let provider = profile.llmProvider
        let baseURL = profile.effectiveBaseURL
        let model = profile.effectiveModel
        
        switch provider {
        case .deepSeek:
            return DeepSeekService(
                baseURLString: baseURL,
                modelName: model,
                apiKeyProvider: { KeychainHelper.shared.getKey(for: .deepSeek) }
            )
        case .openAI:
            return OpenAIService(
                baseURLString: baseURL,
                modelName: model,
                apiKeyProvider: { KeychainHelper.shared.getKey(for: .openAI) }
            )
        case .anthropic:
            return AnthropicService(
                baseURLString: baseURL,
                modelName: model,
                apiKeyProvider: { KeychainHelper.shared.getKey(for: .anthropic) }
            )
        case .gemini:
            return GeminiService(
                baseURLString: baseURL,
                modelName: model,
                apiKeyProvider: { KeychainHelper.shared.getKey(for: .gemini) }
            )
        case .customOpenAI:
            return CustomOpenAIService(
                baseURLString: baseURL,
                modelName: model,
                apiKeyProvider: { KeychainHelper.shared.getKey(for: .customOpenAI) }
            )
        }
    }
    
    public func service(
        for provider: LLMProvider,
        baseURL: String? = nil,
        model: String? = nil,
        apiKey: String? = nil
    ) -> LLMService {
        let endpoint = baseURL ?? provider.defaultBaseURL
        let selectedModel = model ?? provider.defaultModel
        let keyProvider: @Sendable () -> String? = {
            if let key = apiKey {
                return key
            }
            return KeychainHelper.shared.getKey(for: provider)
        }
        
        switch provider {
        case .deepSeek:
            return DeepSeekService(baseURLString: endpoint, modelName: selectedModel, apiKeyProvider: keyProvider)
        case .openAI:
            return OpenAIService(baseURLString: endpoint, modelName: selectedModel, apiKeyProvider: keyProvider)
        case .anthropic:
            return AnthropicService(baseURLString: endpoint, modelName: selectedModel, apiKeyProvider: keyProvider)
        case .gemini:
            return GeminiService(baseURLString: endpoint, modelName: selectedModel, apiKeyProvider: keyProvider)
        case .customOpenAI:
            return CustomOpenAIService(baseURLString: endpoint, modelName: selectedModel, apiKeyProvider: keyProvider)
        }
    }
    
    public var supportedProviders: [LLMProvider] {
        LLMProvider.allCases
    }
    
    public func models(for provider: LLMProvider) -> [String] {
        provider.supportedModels
    }
}
