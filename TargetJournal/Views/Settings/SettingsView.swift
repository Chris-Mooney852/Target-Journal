import SwiftUI
import SwiftData

/// Global App Settings: Target Language, Level, DeepSeek API Key, and Model parameters.
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var userProfile: UserProfile
    
    @State private var apiKey: String = ""
    @State private var isTestingKey: Bool = false
    @State private var testStatus: String?
    @State private var isKeyValid: Bool = false
    @State private var showSavedAlert: Bool = false
    
    public init(userProfile: UserProfile) {
        self.userProfile = userProfile
    }
    
    public var body: some View {
        Form {
            // Target Language & Proficiency Level
            Section("Language & Proficiency") {
                Picker("Target Language", selection: $userProfile.targetLanguageRaw) {
                    ForEach(TargetLanguage.allCases) { lang in
                        Text("\(lang.flagEmoji)  \(lang.displayName) (\(lang.nativeName))")
                            .tag(lang.rawValue)
                    }
                }
                
                Picker("Proficiency Level", selection: $userProfile.currentHSKLevelRaw) {
                    ForEach(userProfile.targetLanguage.supportedLevels) { level in
                        Text("\(level.title) — \(level.proficiencyTier)")
                            .tag(level.rawValue)
                    }
                }
                
                Picker("Explanation Language", selection: $userProfile.nativeLanguage) {
                    Text("English").tag("English")
                    Text("Chinese (中文解释)").tag("Chinese")
                    Text("Japanese (日本語)").tag("Japanese")
                    Text("Korean (한국어)").tag("Korean")
                    Text("Spanish (Español)").tag("Spanish")
                    Text("French (Français)").tag("French")
                }
            }
            
            // AI Tutor & LLM Provider API Key
            Section("\(userProfile.llmProvider.displayName) API Configuration") {
                if userProfile.llmProvider.isAPIKeyRequired {
                    SecureField(userProfile.llmProvider.apiKeyPlaceholder, text: $apiKey)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                } else {
                    TextField(userProfile.llmProvider.apiKeyPlaceholder, text: $apiKey)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                }
                
                HStack {
                    Button(action: testConnection) {
                        if isTestingKey {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("Test Connection")
                        }
                    }
                    .disabled(isTestingKey || (userProfile.llmProvider.isAPIKeyRequired && apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                    
                    Spacer()
                    
                    if let status = testStatus {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(isKeyValid ? .green : .red)
                    }
                }
                
                if !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: {
                        saveSettings()
                        testStatus = "Saved to Keychain ✓"
                        isKeyValid = true
                    }) {
                        Label("Save Key", systemImage: "square.and.arrow.down")
                    }
                    .font(.footnote)
                }
            }
            
            // Advanced Model Settings
            Section("AI Engine") {
                NavigationLink(destination: ModelConfigView(userProfile: userProfile)) {
                    HStack {
                        Label(userProfile.llmProvider.displayName, systemImage: userProfile.llmProvider.iconSystemName)
                        Spacer()
                        Text(userProfile.effectiveModel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // App Info
            Section("About") {
                HStack(spacing: 14) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TargetJournal")
                            .font(.headline)
                        Text("Version 1.0.0 (Build 1)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                
                HStack {
                    Text("Architecture")
                    Spacer()
                    Text("SwiftUI • SwiftData • Swift 6")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    saveSettings()
                    dismiss()
                }
            }
        }
        .onAppear {
            loadKeyForCurrentProvider()
        }
        .onChange(of: userProfile.preferredLLMProvider) { _, _ in
            loadKeyForCurrentProvider()
        }
        .onChange(of: userProfile.targetLanguageRaw) { _, newRaw in
            let lang = TargetLanguage(rawValue: newRaw) ?? .simplifiedChinese
            if !lang.supportedLevels.map({ $0.rawValue }).contains(userProfile.currentHSKLevelRaw) {
                userProfile.currentHSKLevel = lang.defaultLevel
            }
        }
        .onDisappear {
            saveSettings()
        }
    }
    
    private func loadKeyForCurrentProvider() {
        apiKey = KeychainHelper.shared.getKey(for: userProfile.llmProvider) ?? ""
        testStatus = nil
        isKeyValid = false
    }
    
    private func saveSettings() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try KeychainHelper.shared.saveKey(trimmedKey, for: userProfile.llmProvider)
            try modelContext.save()
        } catch {
            print("[SettingsView] Failed to save settings: \(error)")
        }
    }
    
    private func testConnection() {
        let keyToTest = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        isTestingKey = true
        testStatus = nil
        
        let provider = userProfile.llmProvider
        let service = LLMServiceRegistry.shared.service(
            for: provider,
            baseURL: userProfile.effectiveBaseURL,
            model: userProfile.effectiveModel,
            apiKey: keyToTest
        )
        
        Task {
            do {
                let success = try await service.testConnection()
                await MainActor.run {
                    self.isTestingKey = false
                    self.isKeyValid = success
                    self.testStatus = "Connected ✓"
                    if success {
                        try? KeychainHelper.shared.saveKey(keyToTest, for: provider)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isTestingKey = false
                    self.isKeyValid = false
                    self.testStatus = "Failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
