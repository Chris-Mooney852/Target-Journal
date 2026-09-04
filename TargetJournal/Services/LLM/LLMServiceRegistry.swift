import Foundation

/// Central registry and coordinator for all LLM services.
public final class LLMServiceRegistry: Sendable {
    public static let shared = LLMServiceRegistry()
    
    private init() {}
    
    public func service(for profile: UserProfile) -> LLMService {
        switch profile.preferredLLMProvider.lowercased() {
        case "deepseek":
            return DeepSeekService(
                baseURLString: profile.customBaseURL.isEmpty ? "https://api.deepseek.com/chat/completions" : profile.customBaseURL,
                modelName: profile.deepSeekModel.isEmpty ? "deepseek-chat" : profile.deepSeekModel
            )
        default:
            return DeepSeekService()
        }
    }
    
    public var supportedProviders: [String] {
        ["DeepSeek"]
    }
    
    public var supportedModelsForDeepSeek: [String] {
        ["deepseek-chat", "deepseek-reasoner"]
    }
}
