import Foundation
import SwiftData

/// User preferences, target language selection, proficiency, and settings.
@Model
public final class UserProfile {
    public var id: UUID = UUID()
    public var targetLanguageRaw: String = TargetLanguage.simplifiedChinese.rawValue
    public var currentHSKLevelRaw: String = HSKLevel.hsk1.rawValue
    public var nativeLanguage: String = "English"
    public var isOnboardingCompleted: Bool = false
    public var preferredLLMProvider: String = "DeepSeek"
    public var deepSeekModel: String = "deepseek-chat"
    public var customBaseURL: String = "https://api.deepseek.com/chat/completions"
    public var streakCount: Int = 0
    public var lastJournalDate: Date?
    
    public init(
        id: UUID = UUID(),
        targetLanguage: TargetLanguage = .simplifiedChinese,
        currentHSKLevel: HSKLevel = .hsk1,
        nativeLanguage: String = "English",
        isOnboardingCompleted: Bool = false,
        preferredLLMProvider: String = "DeepSeek",
        deepSeekModel: String = "deepseek-chat",
        customBaseURL: String = "https://api.deepseek.com/chat/completions"
    ) {
        self.id = id
        self.targetLanguageRaw = targetLanguage.rawValue
        self.currentHSKLevelRaw = currentHSKLevel.rawValue
        self.nativeLanguage = nativeLanguage
        self.isOnboardingCompleted = isOnboardingCompleted
        self.preferredLLMProvider = preferredLLMProvider
        self.deepSeekModel = deepSeekModel
        self.customBaseURL = customBaseURL
    }
    
    public var targetLanguage: TargetLanguage {
        get { TargetLanguage(rawValue: targetLanguageRaw) ?? .simplifiedChinese }
        set { targetLanguageRaw = newValue.rawValue }
    }
    
    public var currentHSKLevel: HSKLevel {
        get { HSKLevel(rawValue: currentHSKLevelRaw) ?? .hsk1 }
        set { currentHSKLevelRaw = newValue.rawValue }
    }
    
    public var llmProvider: LLMProvider {
        get {
            LLMProvider(rawValue: preferredLLMProvider) ?? .deepSeek
        }
        set {
            preferredLLMProvider = newValue.rawValue
            if !newValue.supportedModels.contains(deepSeekModel) {
                deepSeekModel = newValue.defaultModel
            }
            if customBaseURL.isEmpty || customBaseURL == LLMProvider.deepSeek.defaultBaseURL {
                customBaseURL = newValue.defaultBaseURL
            }
        }
    }
    
    public var effectiveModel: String {
        if !deepSeekModel.isEmpty {
            return deepSeekModel
        }
        return llmProvider.defaultModel
    }
    
    public var effectiveBaseURL: String {
        if !customBaseURL.isEmpty {
            return customBaseURL
        }
        return llmProvider.defaultBaseURL
    }
}
