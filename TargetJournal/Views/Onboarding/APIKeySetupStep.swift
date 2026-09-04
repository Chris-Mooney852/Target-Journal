import SwiftUI

public struct APIKeySetupStep: View {
    @Binding var selectedProvider: LLMProvider
    @Binding var apiKey: String
    @Binding var isValidated: Bool
    
    @State private var isTesting: Bool = false
    @State private var testStatus: String?
    @State private var isSuccess: Bool = false
    
    public init(selectedProvider: Binding<LLMProvider>, apiKey: Binding<String>, isValidated: Binding<Bool>) {
        self._selectedProvider = selectedProvider
        self._apiKey = apiKey
        self._isValidated = isValidated
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Language Tutor")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Select your preferred AI provider to power grammar corrections, vocabulary suggestions, and native phrasing feedback.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("AI Provider")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Picker("Provider", selection: $selectedProvider) {
                    ForEach(LLMProvider.allCases) { provider in
                        Label(provider.displayName, systemImage: provider.iconSystemName)
                            .tag(provider)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                #if os(iOS)
                .background(Color(.secondarySystemGroupedBackground))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(selectedProvider.displayName) API Key")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                if selectedProvider.isAPIKeyRequired {
                    SecureField(selectedProvider.apiKeyPlaceholder, text: $apiKey)
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
                } else {
                    TextField(selectedProvider.apiKeyPlaceholder, text: $apiKey)
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
                .disabled(isTesting || (selectedProvider.isAPIKeyRequired && apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                
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
                message: "Your API key is securely stored in Apple Keychain and sent directly to \(selectedProvider.displayName) over encrypted HTTPS.",
                color: .indigo
            )
            
            Spacer()
        }
        .onChange(of: selectedProvider) { _, newProvider in
            apiKey = KeychainHelper.shared.getKey(for: newProvider) ?? ""
            testStatus = nil
            isSuccess = false
            isValidated = false
        }
    }
    
    private func testConnection() {
        let keyToTest = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        isTesting = true
        testStatus = nil
        
        let provider = selectedProvider
        let service = LLMServiceRegistry.shared.service(for: provider, apiKey: keyToTest)
        
        Task {
            do {
                let success = try await service.testConnection()
                await MainActor.run {
                    self.isTesting = false
                    self.isSuccess = success
                    self.isValidated = success
                    self.testStatus = "Connected successfully!"
                    if success {
                        try? KeychainHelper.shared.saveKey(keyToTest, for: provider)
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
