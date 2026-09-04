import Foundation

/// Balance and credit info for LLM providers that support a balance query API.
public struct LLMBalanceInfo: Sendable, Equatable, Codable {
    public let currency: String
    public let totalBalance: String
    public let grantedBalance: String?
    public let toppedUpBalance: String?
    public let isAvailable: Bool
    
    public init(
        currency: String,
        totalBalance: String,
        grantedBalance: String? = nil,
        toppedUpBalance: String? = nil,
        isAvailable: Bool = true
    ) {
        self.currency = currency
        self.totalBalance = totalBalance
        self.grantedBalance = grantedBalance
        self.toppedUpBalance = toppedUpBalance
        self.isAvailable = isAvailable
    }
    
    public var formattedDisplay: String {
        let sym: String
        switch currency.uppercased() {
        case "CNY", "RMB": sym = "¥"
        case "USD": sym = "$"
        case "EUR": sym = "€"
        default: sym = "\(currency) "
        }
        return "\(sym)\(totalBalance)"
    }
}

/// Protocol that all LLM providers (DeepSeek, OpenAI, Claude, Gemini, Local) must conform to.
public protocol LLMService: Sendable {
    var providerId: String { get }
    var providerName: String { get }
    var supportsBalanceCheck: Bool { get }
    
    /// Analyzes a journal entry based on the user's proficiency level.
    func analyze(request: AnalysisRequest) async throws -> LLMAnalysisResponse
    
    /// Tests connectivity with the configured API key and endpoint.
    func testConnection() async throws -> Bool
    
    /// Fetches the remaining balance if supported by the provider.
    func fetchBalance() async throws -> LLMBalanceInfo?
}

public extension LLMService {
    var supportsBalanceCheck: Bool { false }
    
    func fetchBalance() async throws -> LLMBalanceInfo? {
        return nil
    }
}
