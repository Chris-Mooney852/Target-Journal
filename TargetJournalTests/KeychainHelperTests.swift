import XCTest
#if canImport(TargetJournal)
@testable import TargetJournal
#elseif canImport(TargetJournalCore)
@testable import TargetJournalCore
#endif

final class KeychainHelperTests: XCTestCase {
    
    override func tearDown() {
        try? KeychainHelper.shared.deleteDeepSeekKey()
        super.tearDown()
    }
    
    func testSaveAndRetrieveDeepSeekKey() throws {
        let testKey = "sk-test1234567890abcdef"
        
        try KeychainHelper.shared.saveDeepSeekKey(testKey)
        let retrieved = KeychainHelper.shared.getDeepSeekKey()
        
        XCTAssertEqual(retrieved, testKey)
    }
    
    func testDeleteDeepSeekKey() throws {
        let testKey = "sk-delete-test"
        try KeychainHelper.shared.saveDeepSeekKey(testKey)
        XCTAssertEqual(KeychainHelper.shared.getDeepSeekKey(), testKey)
        
        try KeychainHelper.shared.deleteDeepSeekKey()
        XCTAssertNil(KeychainHelper.shared.getDeepSeekKey())
    }
    
    func testUpdateDeepSeekKey() throws {
        let key1 = "sk-first-key"
        let key2 = "sk-second-key"
        
        try KeychainHelper.shared.saveDeepSeekKey(key1)
        XCTAssertEqual(KeychainHelper.shared.getDeepSeekKey(), key1)
        
        try KeychainHelper.shared.saveDeepSeekKey(key2)
        XCTAssertEqual(KeychainHelper.shared.getDeepSeekKey(), key2)
    }
}
