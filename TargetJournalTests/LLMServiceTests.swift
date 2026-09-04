import XCTest
#if canImport(TargetJournal)
@testable import TargetJournal
#elseif canImport(TargetJournalCore)
@testable import TargetJournalCore
#endif

final class LLMServiceTests: XCTestCase {
    
    func testLLMAnalysisResponseJSONDecoding() throws {
        let jsonString = """
        {
          "overallScore": 88,
          "fluencySummary": "Good foundational structure with minor word order issues.",
          "encouragingFeedback": "You are expressing yourself clearly at the HSK 2 level!",
          "corrections": [
            {
              "original": "我想去明天北京。",
              "corrected": "我明天想去北京。",
              "explanation": "Time words like '明天' usually precede or immediately follow the subject.",
              "category": "Word Order",
              "ruleTag": "Time Word Position"
            }
          ],
          "vocabularyRecommendations": [
            {
              "hanzi": "旅行",
              "pinyin": "lǚxíng",
              "english": "to travel / journey",
              "hskLevel": "HSK 2",
              "exampleSentence": "我想去北京旅行。",
              "contextNote": "More natural than just 去 when referring to a trip."
            }
          ],
          "grammarPatterns": [
            {
              "pattern": "Subject + Time + Verb + Object",
              "explanation": "Standard Mandarin chronological time placement",
              "level": "HSK 1"
            }
          ],
          "polishedVersion": "我明天想去北京旅行。"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(LLMAnalysisResponse.self, from: data)
        
        XCTAssertEqual(response.overallScore, 88)
        XCTAssertEqual(response.corrections.count, 1)
        XCTAssertEqual(response.corrections.first?.original, "我想去明天北京。")
        XCTAssertEqual(response.corrections.first?.corrected, "我明天想去北京。")
        XCTAssertEqual(response.corrections.first?.category, "Word Order")
        XCTAssertEqual(response.vocabularyRecommendations.first?.hanzi, "旅行")
        XCTAssertEqual(response.grammarPatterns.first?.pattern, "Subject + Time + Verb + Object")
        XCTAssertEqual(response.polishedVersion, "我明天想去北京旅行。")
    }
    
    func testDeepSeekServiceMissingApiKeyThrowsError() async {
        let service = DeepSeekService(apiKeyProvider: { nil })
        let request = AnalysisRequest(
            journalContent: "测试",
            title: "Test",
            targetLanguage: .simplifiedChinese,
            userLevel: .hsk1,
            nativeLanguage: "English"
        )
        
        do {
            _ = try await service.analyze(request: request)
            XCTFail("Should have thrown missingApiKey error")
        } catch let error as LLMError {
            switch error {
            case .missingApiKey:
                // Success
                break
            default:
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
