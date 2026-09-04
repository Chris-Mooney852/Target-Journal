import Foundation

/// Specific grammar/vocabulary correction with level-appropriate explanations.
public struct GrammarCorrection: Codable, Identifiable, Sendable, Hashable {
    public var id: String
    public var original: String
    public var corrected: String
    public var explanation: String
    public var category: CorrectionCategory
    public var ruleTag: String?
    
    public init(
        id: String = UUID().uuidString,
        original: String,
        corrected: String,
        explanation: String,
        category: CorrectionCategory = .grammar,
        ruleTag: String? = nil
    ) {
        self.id = id
        self.original = original
        self.corrected = corrected
        self.explanation = explanation
        self.category = category
        self.ruleTag = ruleTag
    }
    
    public var isValidCorrection: Bool {
        GrammarCorrection.isMeaningful(
            original: original,
            corrected: corrected,
            explanation: explanation,
            ruleTag: ruleTag,
            category: category.rawValue
        )
    }
    
    public static func isMeaningful(
        original: String,
        corrected: String,
        explanation: String = "",
        ruleTag: String? = nil,
        category: String = ""
    ) -> Bool {
        let trimmedOriginal = original.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCorrected = corrected.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOriginal.isEmpty, !trimmedCorrected.isEmpty else {
            return false
        }
        
        if trimmedOriginal == trimmedCorrected {
            return false
        }
        
        let noChangePhrases: Set<String> = [
            "no change needed",
            "no change",
            "no changes needed",
            "no changes",
            "no correction needed",
            "no correction",
            "no corrections needed",
            "no corrections",
            "no error",
            "no errors",
            "no errors found",
            "none",
            "n/a",
            "na",
            "nil",
            "null",
            "correct as is",
            "already correct",
            "correct",
            "looks good",
            "all correct",
            "perfect",
            "无需修改",
            "无修改",
            "无需改动",
            "没有错误",
            "无错误",
            "正确",
            "无",
            "无须修改",
            "不需要修改"
        ]
        
        let lowerCorrected = trimmedCorrected
            .lowercased()
            .trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
        
        if noChangePhrases.contains(lowerCorrected) {
            return false
        }
        
        let lowerOriginal = trimmedOriginal
            .lowercased()
            .trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
        
        if noChangePhrases.contains(lowerOriginal) {
            return false
        }
        
        if let rule = ruleTag?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines)),
           noChangePhrases.contains(rule) {
            return false
        }
        
        let lowerCategory = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
        if noChangePhrases.contains(lowerCategory) {
            return false
        }
        
        let lowerExplanation = explanation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
        if noChangePhrases.contains(lowerExplanation) {
            return false
        }
        
        return true
    }
}

public enum CorrectionCategory: String, Codable, CaseIterable, Sendable {
    case grammar = "Grammar"
    case vocabulary = "Vocabulary"
    case wordOrder = "Word Order"
    case toneAndNaturalness = "Natural Phrasing"
    case punctuation = "Punctuation"
    case measureWord = "Measure Word"
}

/// Suggested vocabulary item to help the learner expand their lexicon.
public struct VocabularyItem: Codable, Identifiable, Sendable, Hashable {
    public var id: String
    public var hanzi: String
    public var pinyin: String
    public var english: String
    public var hskLevel: String
    public var exampleSentence: String
    public var contextNote: String?
    
    public init(
        id: String = UUID().uuidString,
        hanzi: String,
        pinyin: String,
        english: String,
        hskLevel: String,
        exampleSentence: String,
        contextNote: String? = nil
    ) {
        self.id = id
        self.hanzi = hanzi
        self.pinyin = pinyin
        self.english = english
        self.hskLevel = hskLevel
        self.exampleSentence = exampleSentence
        self.contextNote = contextNote
    }
}

/// Key grammar pattern analyzed in the journal.
public struct GrammarPatternHighlight: Codable, Identifiable, Sendable, Hashable {
    public var id: String
    public var pattern: String
    public var explanation: String
    public var level: String
    
    public init(
        id: String = UUID().uuidString,
        pattern: String,
        explanation: String,
        level: String
    ) {
        self.id = id
        self.pattern = pattern
        self.explanation = explanation
        self.level = level
    }
}
