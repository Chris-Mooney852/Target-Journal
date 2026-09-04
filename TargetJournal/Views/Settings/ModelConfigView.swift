import SwiftUI

public struct ModelConfigView: View {
    @Bindable var userProfile: UserProfile
    
    public init(userProfile: UserProfile) {
        self.userProfile = userProfile
    }
    
    public var body: some View {
        Form {
            Section("LLM Provider") {
                Picker("Provider", selection: $userProfile.preferredLLMProvider) {
                    ForEach(LLMServiceRegistry.shared.supportedProviders, id: \.self) { provider in
                        Text(provider).tag(provider)
                    }
                }
            }
            
            Section("DeepSeek Model Configuration") {
                Picker("Model", selection: $userProfile.deepSeekModel) {
                    ForEach(LLMServiceRegistry.shared.supportedModelsForDeepSeek, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                
                TextField("Custom API Endpoint", text: $userProfile.customBaseURL)
                    .font(.caption)
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
            }
            
            Section(footer: Text("deepseek-chat provides fast, standard grammar and vocabulary critique. deepseek-reasoner utilizes deep chain-of-thought analysis for complex idioms and subtle tone nuances.")) {
                EmptyView()
            }
        }
        .navigationTitle("AI Model Configuration")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
