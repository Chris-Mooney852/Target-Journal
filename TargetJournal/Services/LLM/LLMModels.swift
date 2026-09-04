import Foundation

/// Request payload sent to LLM for journaling critique.
public struct AnalysisRequest: Sendable {
    public let journalContent: String
    public let title: String
    public let targetLanguage: TargetLanguage
    public let userLevel: HSKLevel
    public let nativeLanguage: String
    
    public init(
        journalContent: String,
        title: String,
        targetLanguage: TargetLanguage,
        userLevel: HSKLevel,
        nativeLanguage: String
    ) {
        self.journalContent = journalContent
        self.title = title
        self.targetLanguage = targetLanguage
        self.userLevel = userLevel
        self.nativeLanguage = nativeLanguage
    }
}

/// Decoded analysis response payload from the LLM.
public struct LLMAnalysisResponse: Codable, Sendable {
    public let overallScore: Int
    public let fluencySummary: String
    public let encouragingFeedback: String
    public let corrections: [LLMCorrectionItem]
    public let vocabularyRecommendations: [LLMVocabularyItem]
    public let grammarPatterns: [LLMGrammarPatternHighlight]
    public let polishedVersion: String
    
    public init(
        overallScore: Int,
        fluencySummary: String,
        encouragingFeedback: String,
        corrections: [LLMCorrectionItem],
        vocabularyRecommendations: [LLMVocabularyItem],
        grammarPatterns: [LLMGrammarPatternHighlight],
        polishedVersion: String
    ) {
        self.overallScore = overallScore
        self.fluencySummary = fluencySummary
        self.encouragingFeedback = encouragingFeedback
        self.corrections = corrections
        self.vocabularyRecommendations = vocabularyRecommendations
        self.grammarPatterns = grammarPatterns
        self.polishedVersion = polishedVersion
    }
}

public struct LLMCorrectionItem: Codable, Sendable {
    public let original: String
    public let corrected: String
    public let explanation: String
    public let category: String
    public let ruleTag: String?
    
    public var isValidCorrection: Bool {
        GrammarCorrection.isMeaningful(
            original: original,
            corrected: corrected,
            explanation: explanation,
            ruleTag: ruleTag,
            category: category
        )
    }
}

public struct LLMVocabularyItem: Codable, Sendable {
    public let hanzi: String
    public let pinyin: String
    public let english: String
    public let hskLevel: String
    public let exampleSentence: String
    public let contextNote: String?
}

public struct LLMGrammarPatternHighlight: Codable, Sendable {
    public let pattern: String
    public let explanation: String
    public let level: String
}

/// Errors occurring during LLM interaction.
public enum LLMError: Error, LocalizedError {
    case missingApiKey(provider: String = "AI")
    case invalidURL
    case invalidRequest(String = "")
    case networkError(String)
    case invalidResponse(statusCode: Int, message: String)
    case decodingError(String)
    case emptyResponse
    
    public var errorDescription: String? {
        switch self {
        case .missingApiKey(let provider):
            return "\(provider) API key is missing. Please add your key in Settings."
        case .invalidURL:
            return "The API endpoint URL is invalid."
        case .invalidRequest(let details):
            return details.isEmpty ? "Failed to construct the analysis request." : "Invalid request: \(details)"
        case .networkError(let details):
            return "Network connection error: \(details)"
        case .invalidResponse(let statusCode, let message):
            return "API returned error \(statusCode): \(message)"
        case .decodingError(let details):
            return "Failed to parse analysis response: \(details)"
        case .emptyResponse:
            return "The AI returned an empty response."
        }
    }
}
