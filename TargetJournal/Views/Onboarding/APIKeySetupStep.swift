import SwiftUI

public struct APIKeySetupStep: View {
    @Binding var apiKey: String
    @Binding var isValidated: Bool
    
    @State private var isTesting: Bool = false
    @State private var testStatus: String?
    @State private var isSuccess: Bool = false
    
    public init(apiKey: Binding<String>, isValidated: Binding<Bool>) {
        self._apiKey = apiKey
        self._isValidated = isValidated
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("AI Tutor Setup (DeepSeek)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your DeepSeek API Key to unlock automated grammar corrections, vocabulary suggestions, and natural phrasing tips.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("DeepSeek API Key")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                SecureField("sk-...", text: $apiKey)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    #if os(iOS)
                    .background(Color(.secondarySystemGroupedBackground))
                    #else
                    .background(Color(.controlBackgroundColor))
                    #endif
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
            }
            
            HStack {
                Button(action: testConnection) {
                    HStack(spacing: 6) {
                        if isTesting {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "network")
                        }
                        Text("Test API Key")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTesting)
                
                Spacer()
                
                if let status = testStatus {
                    HStack(spacing: 4) {
                        Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(isSuccess ? .green : .red)
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(isSuccess ? .green : .red)
                    }
                }
            }
            
            StatusBanner(
                icon: "lock.shield.fill",
                title: "100% Private & Local",
                message: "Your API key is securely stored in your device's Apple Keychain and sent directly to DeepSeek over HTTPS. You can also skip this and enter it later in Settings.",
                color: .indigo
            )
            
            Spacer()
        }
    }
    
    private func testConnection() {
        let keyToTest = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        isTesting = true
        testStatus = nil
        
        let service = DeepSeekService(apiKeyProvider: { keyToTest })
        
        Task {
            do {
                let success = try await service.testConnection()
                await MainActor.run {
                    self.isTesting = false
                    self.isSuccess = success
                    self.isValidated = success
                    self.testStatus = "Connected successfully!"
                    if success {
                        try? KeychainHelper.shared.saveDeepSeekKey(keyToTest)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isTesting = false
                    self.isSuccess = false
                    self.isValidated = false
                    self.testStatus = "Failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
