import XCTest
#if canImport(TargetJournal)
@testable import TargetJournal
#elseif canImport(TargetJournalCore)
@testable import TargetJournalCore
#endif

final class PromptBuilderTests: XCTestCase {
    
    func testPromptBuilderSystemPromptContainsLevelAndLanguage() {
        let request = AnalysisRequest(
            journalContent: "我昨天去商店买了三个苹果。",
            title: "买苹果",
            targetLanguage: .simplifiedChinese,
            userLevel: .hsk2,
            nativeLanguage: "English"
        )
        
        let systemPrompt = PromptBuilder.buildSystemPrompt(for: request)
        
        XCTAssertTrue(systemPrompt.contains("Simplified Chinese"))
        XCTAssertTrue(systemPrompt.contains("HSK 2"))
        XCTAssertTrue(systemPrompt.contains("Elementary"))
        XCTAssertTrue(systemPrompt.contains("English"))
        XCTAssertTrue(systemPrompt.contains("overallScore"))
        XCTAssertTrue(systemPrompt.contains("corrections"))
        XCTAssertTrue(systemPrompt.contains("vocabularyRecommendations"))
    }
    
    func testPromptBuilderUserPromptContainsNoteContent() {
        let content = "我喜欢学中文。每天写日记帮助我提高。"
        let request = AnalysisRequest(
            journalContent: content,
            title: "学中文",
            targetLanguage: .simplifiedChinese,
            userLevel: .hsk3,
            nativeLanguage: "English"
        )
        
        let userPrompt = PromptBuilder.buildUserPrompt(for: request)
        
        XCTAssertTrue(userPrompt.contains("学中文"))
        XCTAssertTrue(userPrompt.contains(content))
    }
}
