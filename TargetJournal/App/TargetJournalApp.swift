import SwiftUI
import SwiftData

@main
struct TargetJournalApp: App {
    let sharedModelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            UserProfile.self,
            JournalEntry.self,
            AnalysisReport.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var activeProfile: UserProfile?
    @State private var showOnboarding: Bool = false
    
    var body: some View {
        Group {
            if let profile = activeProfile {
                if !profile.isOnboardingCompleted || showOnboarding {
                    OnboardingView(userProfile: profile) {
                        showOnboarding = false
                    }
                } else {
                    JournalListView(userProfile: profile)
                }
            } else {
                ProgressView()
                    .task {
                        bootstrapUserProfile()
                    }
            }
        }
    }
    
    private func bootstrapUserProfile() {
        if let existing = profiles.first {
            activeProfile = existing
            showOnboarding = !existing.isOnboardingCompleted
        } else {
            let newProfile = UserProfile(
                targetLanguage: .simplifiedChinese,
                currentHSKLevel: .hsk1,
                nativeLanguage: "English",
                isOnboardingCompleted: false
            )
            modelContext.insert(newProfile)
            try? modelContext.save()
            activeProfile = newProfile
            showOnboarding = true
        }
    }
}
