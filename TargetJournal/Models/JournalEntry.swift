import Foundation
import SwiftData

/// Daily journal entry written in target language with Markdown support.
@Model
public final class JournalEntry {
    public var id: UUID = UUID()
    public var title: String = ""
    public var rawMarkdown: String = ""
    public var date: Date = Date()
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    
    public var targetLanguageRaw: String = "zh_Hans"
    public var recordedHSKLevelRaw: String = "HSK 1"
    
    public var tagsData: Data = Data()
    
    @Relationship(deleteRule: .cascade, inverse: \AnalysisReport.journalEntry)
    public var analysisReports: [AnalysisReport] = []
    
    public init(
        id: UUID = UUID(),
        title: String = "",
        rawMarkdown: String = "",
        date: Date = Date(),
        targetLanguage: TargetLanguage = .simplifiedChinese,
        recordedHSKLevel: HSKLevel = .hsk1,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.rawMarkdown = rawMarkdown
        self.date = date
        self.createdAt = Date()
        self.updatedAt = Date()
        self.targetLanguageRaw = targetLanguage.rawValue
        self.recordedHSKLevelRaw = recordedHSKLevel.rawValue
        self.tags = tags
    }
    
    public var targetLanguage: TargetLanguage {
        get { TargetLanguage(rawValue: targetLanguageRaw) ?? .simplifiedChinese }
        set { targetLanguageRaw = newValue.rawValue }
    }
    
    public var recordedHSKLevel: HSKLevel {
        get { HSKLevel(rawValue: recordedHSKLevelRaw) ?? .hsk1 }
        set { recordedHSKLevelRaw = newValue.rawValue }
    }
    
    public var tags: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: tagsData)) ?? []
        }
        set {
            tagsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    public var latestAnalysis: AnalysisReport? {
        analysisReports.sorted(by: { $0.createdAt > $1.createdAt }).first
    }
    
    /// Estimated character count (vital for Chinese).
    public var characterCount: Int {
        rawMarkdown.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression).count
    }
    
    /// Approximate word count.
    public var wordCount: Int {
        let components = rawMarkdown.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        return max(components.count, characterCount)
    }
}
