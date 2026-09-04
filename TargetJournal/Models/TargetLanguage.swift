import Foundation

/// Represents the language the user is learning.
public enum TargetLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case simplifiedChinese = "zh_Hans"
    case traditionalChinese = "zh_Hant"
    case japanese = "ja"
    case korean = "ko"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case russian = "ru"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .simplifiedChinese: return "Simplified Chinese"
        case .traditionalChinese: return "Traditional Chinese"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .russian: return "Russian"
        }
    }
    
    public var nativeName: String {
        switch self {
        case .simplifiedChinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .russian: return "Русский"
        }
    }
    
    public var flagEmoji: String {
        switch self {
        case .simplifiedChinese: return "🇨🇳"
        case .traditionalChinese: return "🇹🇼"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇧🇷"
        case .russian: return "🇷🇺"
        }
    }
    
    public var localeIdentifier: String {
        switch self {
        case .simplifiedChinese: return "zh-Hans"
        case .traditionalChinese: return "zh-Hant"
        case .japanese: return "ja-JP"
        case .korean: return "ko-KR"
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .italian: return "it-IT"
        case .portuguese: return "pt-BR"
        case .russian: return "ru-RU"
        }
    }
    
    public var levelSystemName: String {
        switch self {
        case .simplifiedChinese: return "HSK (Hànyǔ Shuǐpíng Kǎoshì)"
        case .traditionalChinese: return "TOCFL / HSK"
        case .japanese: return "JLPT (Japanese-Language Proficiency Test)"
        case .korean: return "TOPIK (Test of Proficiency in Korean)"
        case .spanish, .french, .german, .italian, .portuguese: return "CEFR Framework"
        case .russian: return "CEFR / TORFL Framework"
        }
    }
    
    public var defaultLevel: HSKLevel {
        switch self {
        case .simplifiedChinese, .traditionalChinese:
            return .hsk1
        case .japanese:
            return .jlptN5
        case .korean:
            return .topik1
        case .spanish, .french, .german, .italian, .portuguese, .russian:
            return .cefrA1
        }
    }
    
    public var supportedLevels: [HSKLevel] {
        HSKLevel.levels(for: self)
    }
}
