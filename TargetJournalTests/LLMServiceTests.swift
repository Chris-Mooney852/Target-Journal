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
        
        let response = try JSONSanitizer.decodeAnalysisResponse(from: jsonString)
        
        XCTAssertEqual(response.overallScore, 88)
        XCTAssertEqual(response.corrections.count, 1)
        XCTAssertEqual(response.corrections.first?.original, "我想去明天北京。")
        XCTAssertEqual(response.corrections.first?.corrected, "我明天想去北京。")
        XCTAssertEqual(response.corrections.first?.category, "Word Order")
        XCTAssertEqual(response.vocabularyRecommendations.first?.hanzi, "旅行")
        XCTAssertEqual(response.grammarPatterns.first?.pattern, "Subject + Time + Verb + Object")
        XCTAssertEqual(response.polishedVersion, "我明天想去北京旅行。")
    }
    
    func testJSONSanitizerWithMarkdownFences() throws {
        let markdownWrapped = """
        ```json
        {
          "overallScore": 95,
          "fluencySummary": "Excellent expression.",
          "encouragingFeedback": "Keep up the great work!",
          "corrections": [],
          "vocabularyRecommendations": [],
          "grammarPatterns": [],
          "polishedVersion": "今天天气很好。"
        }
        ```
        """
        
        let response = try JSONSanitizer.decodeAnalysisResponse(from: markdownWrapped)
        XCTAssertEqual(response.overallScore, 95)
        XCTAssertEqual(response.polishedVersion, "今天天气很好。")
    }
    
    func testLLMProvidersMetadata() {
        XCTAssertEqual(LLMProvider.allCases.count, 5)
        
        let openAI = LLMProvider.openAI
        XCTAssertEqual(openAI.displayName, "OpenAI")
        XCTAssertTrue(openAI.supportedModels.contains("gpt-4o"))
        XCTAssertEqual(openAI.keychainAccountKey, "openai_api_key")
        
        let anthropic = LLMProvider.anthropic
        XCTAssertEqual(anthropic.displayName, "Anthropic")
        XCTAssertTrue(anthropic.supportedModels.contains("claude-3-7-sonnet-20250219"))
        XCTAssertEqual(anthropic.keychainAccountKey, "anthropic_api_key")
        
        let gemini = LLMProvider.gemini
        XCTAssertEqual(gemini.displayName, "Gemini")
        XCTAssertTrue(gemini.supportedModels.contains("gemini-2.5-flash"))
        XCTAssertEqual(gemini.keychainAccountKey, "gemini_api_key")
        
        let custom = LLMProvider.customOpenAI
        XCTAssertEqual(custom.displayName, "Custom / Ollama")
        XCTAssertFalse(custom.isAPIKeyRequired)
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
            case .missingApiKey(let provider):
                XCTAssertEqual(provider, "DeepSeek")
            default:
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testOpenAIServiceMissingApiKeyThrowsError() async {
        let service = OpenAIService(apiKeyProvider: { nil })
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
            case .missingApiKey(let provider):
                XCTAssertEqual(provider, "OpenAI")
            default:
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testAnthropicServiceMissingApiKeyThrowsError() async {
        let service = AnthropicService(apiKeyProvider: { nil })
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
            case .missingApiKey(let provider):
                XCTAssertEqual(provider, "Anthropic")
            default:
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGeminiServiceMissingApiKeyThrowsError() async {
        let service = GeminiService(apiKeyProvider: { nil })
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
            case .missingApiKey(let provider):
                XCTAssertEqual(provider, "Gemini")
            default:
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testLLMServiceRegistryInstantiatesCorrectService() {
        let profile = UserProfile()
        
        profile.llmProvider = .deepSeek
        let deepseekService = LLMServiceRegistry.shared.service(for: profile)
        XCTAssertEqual(deepseekService.providerName, "DeepSeek")
        
        profile.llmProvider = .openAI
        let openAIService = LLMServiceRegistry.shared.service(for: profile)
        XCTAssertEqual(openAIService.providerName, "OpenAI")
        
        profile.llmProvider = .anthropic
        let anthropicService = LLMServiceRegistry.shared.service(for: profile)
        XCTAssertEqual(anthropicService.providerName, "Anthropic")
        
        profile.llmProvider = .gemini
        let geminiService = LLMServiceRegistry.shared.service(for: profile)
        XCTAssertEqual(geminiService.providerName, "Gemini")
        
        profile.llmProvider = .customOpenAI
        let customService = LLMServiceRegistry.shared.service(for: profile)
        XCTAssertEqual(customService.providerName, "Custom / Ollama")
    }

    func testLLMBalanceInfoFormatting() {
        let cnyBalance = LLMBalanceInfo(currency: "CNY", totalBalance: "12.50", grantedBalance: "0.00", toppedUpBalance: "12.50", isAvailable: true)
        XCTAssertEqual(cnyBalance.formattedDisplay, "¥12.50")
        XCTAssertTrue(cnyBalance.isAvailable)
        
        let usdBalance = LLMBalanceInfo(currency: "USD", totalBalance: "5.00")
        XCTAssertEqual(usdBalance.formattedDisplay, "$5.00")
    }
    
    func testDeepSeekServiceSupportsBalanceCheck() {
        let deepseekService = DeepSeekService()
        XCTAssertTrue(deepseekService.supportsBalanceCheck)
        
        let openAIService = OpenAIService()
        XCTAssertFalse(openAIService.supportsBalanceCheck)
    }
}
