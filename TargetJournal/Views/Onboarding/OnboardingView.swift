import SwiftUI
import SwiftData

/// Multi-step onboarding experience.
public struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    var userProfile: UserProfile
    var onComplete: () -> Void
    
    @State private var currentStep: Int = 0
    @State private var selectedLanguage: TargetLanguage = .simplifiedChinese
    @State private var selectedLevel: HSKLevel = .hsk1
    @State private var apiKey: String = ""
    @State private var isKeyValidated: Bool = false
    
    public init(userProfile: UserProfile, onComplete: @escaping () -> Void) {
        self.userProfile = userProfile
        self.onComplete = onComplete
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Content Step
                TabView(selection: $currentStep) {
                    LanguageSelectionStep(selectedLanguage: $selectedLanguage)
                        .tag(0)
                        .padding(.horizontal, 20)
                    
                    LevelSelectionStep(selectedLevel: $selectedLevel, language: selectedLanguage)
                        .tag(1)
                        .padding(.horizontal, 20)
                    
                    APIKeySetupStep(apiKey: $apiKey, isValidated: $isKeyValidated)
                        .tag(2)
                        .padding(.horizontal, 20)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                
                // Bottom Navigation Buttons
                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(action: handleNextOrFinish) {
                        Text(currentStep == 2 ? "Get Started" : "Continue")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            #if os(iOS)
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            #else
            .background(Color(.windowBackgroundColor))
            #endif
            .navigationTitle("Welcome to TargetJournal")
        }
        .onAppear {
            selectedLanguage = userProfile.targetLanguage
            selectedLevel = userProfile.currentHSKLevel
            if let key = KeychainHelper.shared.getDeepSeekKey() {
                apiKey = key
            }
        }
    }
    
    private func handleNextOrFinish() {
        if currentStep < 2 {
            withAnimation {
                currentStep += 1
            }
        } else {
            // Save settings
            userProfile.targetLanguage = selectedLanguage
            userProfile.currentHSKLevel = selectedLevel
            userProfile.isOnboardingCompleted = true
            
            if !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                try? KeychainHelper.shared.saveDeepSeekKey(apiKey)
            }
            
            try? modelContext.save()
            onComplete()
        }
    }
}
