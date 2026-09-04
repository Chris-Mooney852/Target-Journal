import XCTest
import SwiftData
#if canImport(TargetJournal)
@testable import TargetJournal
#elseif canImport(TargetJournalCore)
@testable import TargetJournalCore
#endif

final class ModelTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    @MainActor
    override func setUp() async throws {
        let schema = Schema([
            UserProfile.self,
            JournalEntry.self,
            AnalysisReport.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext
    }
    
    override func tearDown() {
        modelContainer = nil
        modelContext = nil
    }
    
    func testTargetLanguageProperties() {
        XCTAssertEqual(TargetLanguage.allCases.count, 10)
        
        let chinese = TargetLanguage.simplifiedChinese
        XCTAssertEqual(chinese.rawValue, "zh_Hans")
        XCTAssertEqual(chinese.displayName, "Simplified Chinese")
        XCTAssertEqual(chinese.nativeName, "简体中文")
        XCTAssertEqual(chinese.flagEmoji, "🇨🇳")
        XCTAssertEqual(chinese.defaultLevel, .hsk1)
        
        let japanese = TargetLanguage.japanese
        XCTAssertEqual(japanese.displayName, "Japanese")
        XCTAssertEqual(japanese.nativeName, "日本語")
        XCTAssertEqual(japanese.flagEmoji, "🇯🇵")
        XCTAssertEqual(japanese.defaultLevel, .jlptN5)
        XCTAssertEqual(japanese.supportedLevels.count, 5)
        
        let spanish = TargetLanguage.spanish
        XCTAssertEqual(spanish.displayName, "Spanish")
        XCTAssertEqual(spanish.nativeName, "Español")
        XCTAssertEqual(spanish.flagEmoji, "🇪🇸")
        XCTAssertEqual(spanish.defaultLevel, .cefrA1)
        XCTAssertEqual(spanish.supportedLevels.count, 6)
    }
    
    func testHSKLevelProperties() {
        let hsk3 = HSKLevel.hsk3
        XCTAssertEqual(hsk3.title, "HSK 3")
        XCTAssertEqual(hsk3.proficiencyTier, "Intermediate")
        XCTAssertEqual(hsk3.vocabularyTarget, "~600 words")
        XCTAssertFalse(hsk3.description.isEmpty)
        XCTAssertFalse(hsk3.badgeColorHex.isEmpty)
        
        let jlptN2 = HSKLevel.jlptN2
        XCTAssertEqual(jlptN2.title, "JLPT N2")
        XCTAssertEqual(jlptN2.proficiencyTier, "Upper Intermediate")
        
        let cefrB2 = HSKLevel.cefrB2
        XCTAssertEqual(cefrB2.title, "CEFR B2")
        XCTAssertEqual(cefrB2.proficiencyTier, "Upper Intermediate")
    }
    
    @MainActor
    func testJournalEntryTitleAutoFillsWithDateFormat() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 4
        components.hour = 12
        let fixedDate = calendar.date(from: components)!
        
        let expectedTitle = JournalEntry.formattedDateTitle(for: fixedDate)
        XCTAssertEqual(expectedTitle, "04-09-2026")
        
        let entryWithEmptyTitle = JournalEntry(
            title: "",
            date: fixedDate
        )
        XCTAssertEqual(entryWithEmptyTitle.title, "04-09-2026")
        
        let entryWithCustomTitle = JournalEntry(
            title: "Custom Title",
            date: fixedDate
        )
        XCTAssertEqual(entryWithCustomTitle.title, "Custom Title")
    }
    
    @MainActor
    func testJournalEntryAndAnalysisReportPersistence() throws {
        let entry = JournalEntry(
            title: "今天的天气很好",
            rawMarkdown: "# 今天\n今天我去公园散步了。公园里有很多花。",
            targetLanguage: .simplifiedChinese,
            recordedHSKLevel: .hsk2,
            tags: ["daily", "park"]
        )
        
        modelContext.insert(entry)
        try modelContext.save()
        
        XCTAssertEqual(entry.characterCount, 21)
        XCTAssertEqual(entry.tags.count, 2)
        XCTAssertEqual(entry.tags, ["daily", "park"])
        
        let report = AnalysisReport(
            providerName: "DeepSeek",
            modelUsed: "deepseek-chat",
            evaluatedLevel: "HSK 2",
            overallScore: 92,
            fluencySummary: "Great usage of simple sentences.",
            encouragingFeedback: "Keep up the great work!",
            corrections: [
                GrammarCorrection(
                    original: "我想去明天公园散步。",
                    corrected: "我明天想去公园散步。",
                    explanation: "Time words should be placed before or directly after the subject.",
                    category: .wordOrder,
                    ruleTag: "Time Word Position"
                )
            ],
            vocabularyRecommendations: [
                VocabularyItem(
                    hanzi: "风景",
                    pinyin: "fēngjǐng",
                    english: "scenery / landscape",
                    hskLevel: "HSK 2",
                    exampleSentence: "公园的风景很美。"
                )
            ],
            grammarPatterns: [
                GrammarPatternHighlight(
                    pattern: "在 + Place + Verb",
                    explanation: "Action taking place at a location",
                    level: "HSK 1"
                )
            ],
            polishedVersion: "今天我明天想去公园散步。公园里的花真漂亮。"
        )
        
        report.journalEntry = entry
        entry.analysisReports.append(report)
        modelContext.insert(report)
        try modelContext.save()
        
        XCTAssertEqual(entry.analysisReports.count, 1)
        XCTAssertNotNil(entry.latestAnalysis)
        XCTAssertEqual(entry.latestAnalysis?.overallScore, 92)
        XCTAssertEqual(entry.latestAnalysis?.corrections.count, 1)
        XCTAssertEqual(entry.latestAnalysis?.corrections.first?.original, "我想去明天公园散步。")
        XCTAssertEqual(entry.latestAnalysis?.corrections.first?.corrected, "我明天想去公园散步。")
        XCTAssertEqual(entry.latestAnalysis?.vocabularyRecommendations.count, 1)
        XCTAssertEqual(entry.latestAnalysis?.vocabularyRecommendations.first?.hanzi, "风景")
    }
    
    @MainActor
    func testUserProfileDefaults() throws {
        let profile = UserProfile(
            targetLanguage: .simplifiedChinese,
            currentHSKLevel: .hsk3,
            nativeLanguage: "English",
            isOnboardingCompleted: true
        )
        modelContext.insert(profile)
        try modelContext.save()
        
        XCTAssertEqual(profile.targetLanguage, .simplifiedChinese)
        XCTAssertEqual(profile.currentHSKLevel, .hsk3)
        XCTAssertEqual(profile.preferredLLMProvider, "DeepSeek")
        XCTAssertEqual(profile.deepSeekModel, "deepseek-chat")
    }
    
    @MainActor
    func testGrammarCorrectionFiltersNoChangeNeeded() throws {
        // 1. Identical original and corrected
        let identical = GrammarCorrection(
            original: "我去公园散步了",
            corrected: "我去公园散步了",
            explanation: "No errors here.",
            category: .grammar
        )
        XCTAssertFalse(identical.isValidCorrection)
        
        // 2. Corrected indicates no change needed
        let noChange = GrammarCorrection(
            original: "我喜欢看书",
            corrected: "No change needed",
            explanation: "The sentence is already natural.",
            category: .grammar
        )
        XCTAssertFalse(noChange.isValidCorrection)
        
        let correctAsIs = GrammarCorrection(
            original: "今天很好",
            corrected: "Correct as is",
            explanation: "Good job",
            category: .grammar
        )
        XCTAssertFalse(correctAsIs.isValidCorrection)
        
        let chineseNoChange = GrammarCorrection(
            original: "今天天气很好",
            corrected: "无需修改",
            explanation: "句子正确",
            category: .grammar
        )
        XCTAssertFalse(chineseNoChange.isValidCorrection)
        
        // 3. Rule tag indicates no change needed
        let ruleTagNoChange = GrammarCorrection(
            original: "我爱学习",
            corrected: "我爱学习。",
            explanation: "Added period",
            category: .punctuation,
            ruleTag: "No change needed"
        )
        XCTAssertFalse(ruleTagNoChange.isValidCorrection)
        
        // 4. Valid correction
        let valid = GrammarCorrection(
            original: "我想去明天北京。",
            corrected: "我明天想去北京。",
            explanation: "Time word order issue",
            category: .wordOrder,
            ruleTag: "Word Order"
        )
        XCTAssertTrue(valid.isValidCorrection)
    }
    
    @MainActor
    func testAnalysisReportFiltersInvalidCorrectionsOnSetAndGet() throws {
        let report = AnalysisReport(
            corrections: [
                GrammarCorrection(
                    original: "我去公园",
                    corrected: "我去公园",
                    explanation: "Identical",
                    category: .grammar
                ),
                GrammarCorrection(
                    original: "我想去明天北京。",
                    corrected: "我明天想去北京。",
                    explanation: "Valid correction",
                    category: .wordOrder
                ),
                GrammarCorrection(
                    original: "天气很好",
                    corrected: "No change needed",
                    explanation: "Already correct",
                    category: .grammar
                )
            ]
        )
        
        XCTAssertEqual(report.corrections.count, 1)
        XCTAssertEqual(report.corrections.first?.original, "我想去明天北京。")
        XCTAssertEqual(report.corrections.first?.corrected, "我明天想去北京。")
    }
}
