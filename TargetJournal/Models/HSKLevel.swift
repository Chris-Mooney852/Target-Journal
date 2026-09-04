import Foundation

/// Represents language proficiency levels across HSK, JLPT, TOPIK, and CEFR frameworks.
public enum HSKLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    // MARK: - Chinese (HSK)
    case hsk1 = "HSK 1"
    case hsk2 = "HSK 2"
    case hsk3 = "HSK 3"
    case hsk4 = "HSK 4"
    case hsk5 = "HSK 5"
    case hsk6 = "HSK 6"
    case hsk7to9 = "HSK 7-9"
    
    // MARK: - Japanese (JLPT)
    case jlptN5 = "JLPT N5"
    case jlptN4 = "JLPT N4"
    case jlptN3 = "JLPT N3"
    case jlptN2 = "JLPT N2"
    case jlptN1 = "JLPT N1"
    
    // MARK: - Korean (TOPIK)
    case topik1 = "TOPIK 1"
    case topik2 = "TOPIK 2"
    case topik3 = "TOPIK 3"
    case topik4 = "TOPIK 4"
    case topik5 = "TOPIK 5"
    case topik6 = "TOPIK 6"
    
    // MARK: - European / CEFR (Spanish, French, German, Italian, Portuguese, Russian)
    case cefrA1 = "CEFR A1"
    case cefrA2 = "CEFR A2"
    case cefrB1 = "CEFR B1"
    case cefrB2 = "CEFR B2"
    case cefrC1 = "CEFR C1"
    case cefrC2 = "CEFR C2"
    
    public var id: String { rawValue }
    public var title: String { rawValue }
    
    public var proficiencyTier: String {
        switch self {
        case .hsk1, .jlptN5, .topik1, .cefrA1:
            return "Beginner"
        case .hsk2, .jlptN4, .topik2, .cefrA2:
            return "Elementary"
        case .hsk3, .jlptN3, .topik3, .cefrB1:
            return "Intermediate"
        case .hsk4, .jlptN2, .topik4, .cefrB2:
            return "Upper Intermediate"
        case .hsk5, .topik5, .cefrC1:
            return "Advanced"
        case .hsk6, .jlptN1, .topik6, .cefrC2:
            return "Proficient / Fluent"
        case .hsk7to9:
            return "Mastery / Near-Native"
        }
    }
    
    public var vocabularyTarget: String {
        switch self {
        case .hsk1: return "~150 words"
        case .hsk2: return "~300 words"
        case .hsk3: return "~600 words"
        case .hsk4: return "~1,200 words"
        case .hsk5: return "~2,500 words"
        case .hsk6: return "~5,000 words"
        case .hsk7to9: return "10,000+ words"
            
        case .jlptN5: return "~800 words"
        case .jlptN4: return "~1,500 words"
        case .jlptN3: return "~3,750 words"
        case .jlptN2: return "~6,000 words"
        case .jlptN1: return "10,000+ words"
            
        case .topik1: return "~1,000 words"
        case .topik2: return "~2,000 words"
        case .topik3: return "~4,000 words"
        case .topik4: return "~6,000 words"
        case .topik5: return "~8,000 words"
        case .topik6: return "10,000+ words"
            
        case .cefrA1: return "~500 words"
        case .cefrA2: return "~1,000 words"
        case .cefrB1: return "~2,000 words"
        case .cefrB2: return "~4,000 words"
        case .cefrC1: return "~8,000 words"
        case .cefrC2: return "16,000+ words"
        }
    }
    
    public var description: String {
        switch self {
        // HSK
        case .hsk1:
            return "Can understand and use simple Chinese phrases and meet basic communication needs."
        case .hsk2:
            return "Can communicate simply and directly on familiar daily topics."
        case .hsk3:
            return "Can complete daily life, study, and work tasks in Chinese. Can handle most travel scenarios."
        case .hsk4:
            return "Can discuss topics in a wide range of domains and converse fluently with native speakers."
        case .hsk5:
            return "Can read Chinese newspapers/magazines, enjoy Chinese films, and write full essays."
        case .hsk6:
            return "Can easily understand any written or spoken Chinese information and express themselves smoothly."
        case .hsk7to9:
            return "Can conduct academic, professional, and cultural discourse with nuanced native mastery."
            
        // JLPT
        case .jlptN5:
            return "Can read basic hiragana, katakana, and elementary kanji; understand simple daily expressions."
        case .jlptN4:
            return "Can understand basic Japanese in everyday contexts spoken slowly with basic sentence structures."
        case .jlptN3:
            return "Can understand Japanese used in everyday situations to a certain degree with intermediate grammar."
        case .jlptN2:
            return "Can understand Japanese in everyday and broader circumstances; read news articles and commentary."
        case .jlptN1:
            return "Can comprehend complex abstract writings and express nuanced thoughts with native-like fluency."
            
        // TOPIK
        case .topik1:
            return "Can carry out basic survival conversations (introducing oneself, ordering food, purchasing items)."
        case .topik2:
            return "Can talk about familiar topics such as hobbies, daily routines, and make basic phone inquiries."
        case .topik3:
            return "Can use public facilities and sustain social relationships with standard conversational fluency."
        case .topik4:
            return "Can understand news broadcasts, read newspapers, and write structured topical essays."
        case .topik5:
            return "Can perform research and professional duties; understand specialized political/economic topics."
        case .topik6:
            return "Can perform work and research in specialized professional domains without linguistic barriers."
            
        // CEFR
        case .cefrA1:
            return "Can recognize and use familiar everyday expressions and very basic phrases."
        case .cefrA2:
            return "Can communicate in simple, routine tasks requiring a direct exchange of information on familiar topics."
        case .cefrB1:
            return "Can understand the main points of clear standard input on familiar matters encountered at work, school, and leisure."
        case .cefrB2:
            return "Can understand complex text on concrete and abstract topics and interact with native speakers fluently."
        case .cefrC1:
            return "Can express ideas fluently and spontaneously for social, academic, and professional purposes."
        case .cefrC2:
            return "Can understand with ease virtually everything heard or read; summarize information and reconstruct arguments seamlessly."
        }
    }
    
    public var badgeColorHex: String {
        switch self {
        case .hsk1, .jlptN5, .topik1, .cefrA1: return "34C759" // Green
        case .hsk2, .jlptN4, .topik2, .cefrA2: return "30B0C7" // Teal
        case .hsk3, .jlptN3, .topik3, .cefrB1: return "007AFF" // Blue
        case .hsk4, .jlptN2, .topik4, .cefrB2: return "5856D6" // Indigo
        case .hsk5, .topik5, .cefrC1: return "AF52DE" // Purple
        case .hsk6, .jlptN1, .topik6, .cefrC2: return "FF9500" // Orange
        case .hsk7to9: return "FF2D55" // Pink/Red
        }
    }
    
    public static func levels(for language: TargetLanguage) -> [HSKLevel] {
        switch language {
        case .simplifiedChinese, .traditionalChinese:
            return [.hsk1, .hsk2, .hsk3, .hsk4, .hsk5, .hsk6, .hsk7to9]
        case .japanese:
            return [.jlptN5, .jlptN4, .jlptN3, .jlptN2, .jlptN1]
        case .korean:
            return [.topik1, .topik2, .topik3, .topik4, .topik5, .topik6]
        case .spanish, .french, .german, .italian, .portuguese, .russian:
            return [.cefrA1, .cefrA2, .cefrB1, .cefrB2, .cefrC1, .cefrC2]
        }
    }
}

/// Alias for language proficiency level across all supported languages.
public typealias ProficiencyLevel = HSKLevel
