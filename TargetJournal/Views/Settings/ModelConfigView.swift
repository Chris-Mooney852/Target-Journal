import SwiftUI

public struct ModelConfigView: View {
    @Bindable var userProfile: UserProfile
    
    public init(userProfile: UserProfile) {
        self.userProfile = userProfile
    }
    
    public var body: some View {
        Form {
            Section("LLM Provider") {
                Picker("Provider", selection: $userProfile.llmProvider) {
                    ForEach(LLMProvider.allCases) { provider in
                        Label(provider.displayName, systemImage: provider.iconSystemName)
                            .tag(provider)
                    }
                }
            }
            
            Section("\(userProfile.llmProvider.displayName) Model") {
                Picker("Model", selection: $userProfile.deepSeekModel) {
                    ForEach(userProfile.llmProvider.supportedModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("API Endpoint")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("API Endpoint URL", text: $userProfile.customBaseURL)
                        .font(.caption)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                }
                
                Button("Reset to Default URL") {
                    userProfile.customBaseURL = userProfile.llmProvider.defaultBaseURL
                }
                .font(.footnote)
            }
            
            Section(footer: providerFooterText) {
                EmptyView()
            }
        }
        .navigationTitle("AI Model Configuration")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private var providerFooterText: some View {
        Group {
            switch userProfile.llmProvider {
            case .deepSeek:
                Text("deepseek-chat provides fast, cost-effective grammar corrections. deepseek-reasoner utilizes deep chain-of-thought analysis for complex idioms and subtle tone nuances.")
            case .openAI:
                Text("gpt-4o and gpt-4o-mini offer reliable fluency scoring and vocabulary recommendations. o3-mini provides deep reasoning for intricate Chinese grammatical patterns.")
            case .anthropic:
                Text("Claude 3.7 Sonnet and 3.5 Sonnet excel at natural language nuances, cultural context, and idiomatic Chinese feedback.")
            case .gemini:
                Text("Google Gemini 2.5 Flash and Pro provide high speed, strong multilingual parsing, and rich explanations.")
            case .customOpenAI:
                Text("Use any OpenAI-compatible server (Ollama, LM Studio, vLLM, Groq, OpenRouter). Default is localhost:11434 for local offline models like Qwen 2.5.")
            }
        }
    }
}
