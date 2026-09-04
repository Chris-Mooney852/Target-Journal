import Foundation

/// Utility to clean and extract JSON payloads from LLM text responses.
public enum JSONSanitizer {
    public static func sanitize(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code fence ```json ... ```
        if text.hasPrefix("```json") {
            text = String(text.dropFirst(7))
        } else if text.hasPrefix("```JSON") {
            text = String(text.dropFirst(7))
        } else if text.hasPrefix("```") {
            text = String(text.dropFirst(3))
        }
        
        if text.hasSuffix("```") {
            text = String(text.dropLast(3))
        }
        
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If content is surrounded by extra text outside the first { and last }, slice it
        if let firstBrace = text.firstIndex(of: "{"),
           let lastBrace = text.lastIndex(of: "}"),
           firstBrace <= lastBrace {
            text = String(text[firstBrace...lastBrace])
        }
        
        return text
    }
    
    public static func decodeAnalysisResponse(from rawContent: String) throws -> LLMAnalysisResponse {
        let cleaned = sanitize(rawContent)
        guard let data = cleaned.data(using: .utf8) else {
            throw LLMError.decodingError("Could not convert content to UTF-8 data")
        }
        
        do {
            return try JSONDecoder().decode(LLMAnalysisResponse.self, from: data)
        } catch {
            throw LLMError.decodingError("JSON decoding failed: \(error.localizedDescription)\nContent: \(cleaned)")
        }
    }
}
