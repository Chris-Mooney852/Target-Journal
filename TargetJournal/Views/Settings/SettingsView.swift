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
                        HStack {
                            Text(lang.flagEmoji)
                            Text(lang.displayName)
                        }
                        .tag(lang.rawValue)
                    }
                }
                
                Picker("Proficiency Level", selection: $userProfile.currentHSKLevelRaw) {
                    ForEach(HSKLevel.allCases) { level in
                        HStack {
                            Text(level.title)
                            Text("(\(level.proficiencyTier))")
                                .foregroundStyle(.secondary)
                        }
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
            
            // DeepSeek API Key
            Section("DeepSeek AI Tutor API Key") {
                SecureField("Enter API Key (sk-...)", text: $apiKey)
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                
                HStack {
                    Button(action: testConnection) {
                        if isTestingKey {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("Test Connection")
                        }
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTestingKey)
                    
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
                        Text("Model Settings")
                        Spacer()
                        Text("\(userProfile.preferredLLMProvider) (\(userProfile.deepSeekModel))")
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
            if let storedKey = KeychainHelper.shared.getDeepSeekKey() {
                apiKey = storedKey
            }
        }
        .onDisappear {
            saveSettings()
        }
    }
    
    private func saveSettings() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try KeychainHelper.shared.saveDeepSeekKey(trimmedKey)
            try modelContext.save()
        } catch {
            print("[SettingsView] Failed to save settings: \(error)")
        }
    }
    
    private func testConnection() {
        let keyToTest = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        isTestingKey = true
        testStatus = nil
        
        let service = DeepSeekService(apiKeyProvider: { keyToTest })
        
        Task {
            do {
                let success = try await service.testConnection()
                await MainActor.run {
                    self.isTestingKey = false
                    self.isKeyValid = success
                    self.testStatus = "Valid Key ✓"
                    if success {
                        try? KeychainHelper.shared.saveDeepSeekKey(keyToTest)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isTestingKey = false
                    self.isKeyValid = false
                    self.testStatus = "Invalid: \(error.localizedDescription)"
                }
            }
        }
    }
}
