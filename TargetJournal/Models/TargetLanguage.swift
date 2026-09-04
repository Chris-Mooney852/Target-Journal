import Foundation

/// Represents the language the user is learning.
public enum TargetLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case simplifiedChinese = "zh_Hans"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .simplifiedChinese:
            return "Simplified Chinese"
        }
    }
    
    public var nativeName: String {
        switch self {
        case .simplifiedChinese:
            return "简体中文"
        }
    }
    
    public var flagEmoji: String {
        switch self {
        case .simplifiedChinese:
            return "🇨🇳"
        }
    }
    
    public var localeIdentifier: String {
        switch self {
        case .simplifiedChinese:
            return "zh-Hans"
        }
    }
    
    public var levelSystemName: String {
        switch self {
        case .simplifiedChinese:
            return "HSK (Hànyǔ Shuǐpíng Kǎoshì)"
        }
    }
}
