import Foundation

/// Represents Chinese proficiency levels (HSK 1 through HSK 9).
public enum HSKLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case hsk1 = "HSK 1"
    case hsk2 = "HSK 2"
    case hsk3 = "HSK 3"
    case hsk4 = "HSK 4"
    case hsk5 = "HSK 5"
    case hsk6 = "HSK 6"
    case hsk7to9 = "HSK 7-9"
    
    public var id: String { rawValue }
    
    public var title: String {
        rawValue
    }
    
    public var proficiencyTier: String {
        switch self {
        case .hsk1:
            return "Beginner"
        case .hsk2:
            return "Elementary"
        case .hsk3:
            return "Intermediate"
        case .hsk4:
            return "Upper Intermediate"
        case .hsk5:
            return "Advanced"
        case .hsk6:
            return "Proficient"
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
        }
    }
    
    public var description: String {
        switch self {
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
        }
    }
    
    public var badgeColorHex: String {
        switch self {
        case .hsk1: return "34C759" // Green
        case .hsk2: return "30B0C7" // Teal
        case .hsk3: return "007AFF" // Blue
        case .hsk4: return "5856D6" // Indigo
        case .hsk5: return "AF52DE" // Purple
        case .hsk6: return "FF9500" // Orange
        case .hsk7to9: return "FF2D55" // Pink/Red
        }
    }
}
