import Foundation

/// Supported LLM Providers for language analysis and tutoring.
public enum LLMProvider: String, CaseIterable, Identifiable, Codable, Sendable {
    case deepSeek = "DeepSeek"
    case openAI = "OpenAI"
    case anthropic = "Anthropic"
    case gemini = "Gemini"
    case customOpenAI = "Custom / Ollama"
    
    public var id: String { rawValue }
    public var displayName: String { rawValue }
    
    public var defaultBaseURL: String {
        switch self {
        case .deepSeek:
            return "https://api.deepseek.com/chat/completions"
        case .openAI:
            return "https://api.openai.com/v1/chat/completions"
        case .anthropic:
            return "https://api.anthropic.com/v1/messages"
        case .gemini:
            return "https://generativelanguage.googleapis.com/v1beta"
        case .customOpenAI:
            return "http://localhost:11434/v1/chat/completions"
        }
    }
    
    public var defaultModel: String {
        switch self {
        case .deepSeek:
            return "deepseek-chat"
        case .openAI:
            return "gpt-4o"
        case .anthropic:
            return "claude-3-7-sonnet-20250219"
        case .gemini:
            return "gemini-2.5-flash"
        case .customOpenAI:
            return "qwen2.5:latest"
        }
    }
    
    public var supportedModels: [String] {
        switch self {
        case .deepSeek:
            return ["deepseek-chat", "deepseek-reasoner"]
        case .openAI:
            return ["gpt-4o", "gpt-4o-mini", "o3-mini", "gpt-4.5-preview"]
        case .anthropic:
            return ["claude-3-7-sonnet-20250219", "claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022"]
        case .gemini:
            return ["gemini-2.5-flash", "gemini-2.5-pro", "gemini-2.0-flash"]
        case .customOpenAI:
            return ["qwen2.5:latest", "llama3.3:latest", "mistral-small:latest", "custom"]
        }
    }
    
    public var keychainAccountKey: String {
        switch self {
        case .deepSeek: return "deepseek_api_key"
        case .openAI: return "openai_api_key"
        case .anthropic: return "anthropic_api_key"
        case .gemini: return "gemini_api_key"
        case .customOpenAI: return "custom_llm_api_key"
        }
    }
    
    public var apiKeyPlaceholder: String {
        switch self {
        case .deepSeek: return "sk-..."
        case .openAI: return "sk-proj-..."
        case .anthropic: return "sk-ant-..."
        case .gemini: return "AIzaSy..."
        case .customOpenAI: return "Optional for Ollama / Enter API Key"
        }
    }
    
    public var isAPIKeyRequired: Bool {
        switch self {
        case .customOpenAI: return false
        default: return true
        }
    }
    
    public var iconSystemName: String {
        switch self {
        case .deepSeek: return "sparkles"
        case .openAI: return "cpu"
        case .anthropic: return "brain.head.profile"
        case .gemini: return "sparkle"
        case .customOpenAI: return "server.rack"
        }
    }
}
