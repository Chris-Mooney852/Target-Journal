import SwiftUI

/// Header displaying daily streak, word count stats, active target language level, and LLM remaining balance.
public struct StreakHeaderView: View {
    public let userProfile: UserProfile
    public let totalEntries: Int
    public let totalCharacters: Int
    
    @State private var balanceInfo: LLMBalanceInfo?
    @State private var isFetchingBalance: Bool = false
    @State private var balanceError: String?
    
    public init(userProfile: UserProfile, totalEntries: Int, totalCharacters: Int) {
        self.userProfile = userProfile
        self.totalEntries = totalEntries
        self.totalCharacters = totalCharacters
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            // Main Stats Row: Target Language + Streak/Characters
            HStack(spacing: 12) {
                // Target Language & Level Card
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(userProfile.targetLanguage.flagEmoji)
                            .font(.title2)
                        Text(userProfile.targetLanguage.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    
                    HSKBadge(level: userProfile.currentHSKLevel, style: .standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(14)
                #if os(iOS)
                .background(Color(.secondarySystemGroupedBackground))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                // Stats Card (Day Streak & Characters)
                HStack(spacing: 12) {
                    statColumn(
                        icon: "flame.fill",
                        iconColor: .orange,
                        value: "\(userProfile.streakCount)",
                        label: "Day Streak"
                    )
                    
                    statColumn(
                        icon: "character.book.closed.fill",
                        iconColor: .blue,
                        value: "\(totalCharacters)",
                        label: "Characters"
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(14)
                #if os(iOS)
                .background(Color(.secondarySystemGroupedBackground))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .fixedSize(horizontal: false, vertical: true)
            
            // AI Tutor & Remaining Balance Row
            Button(action: refreshBalance) {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: userProfile.llmProvider.iconSystemName)
                            .font(.subheadline)
                            .foregroundStyle(Color.accentColor)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 4) {
                                Text(userProfile.llmProvider.displayName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                
                                Text("• \(userProfile.effectiveModel)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text("AI Tutor Engine")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Balance or Status Display
                    if isFetchingBalance {
                        ProgressView()
                            .controlSize(.small)
                    } else if let balance = balanceInfo {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(balance.isAvailable ? Color.green : Color.orange)
                                .frame(width: 7, height: 7)
                            
                            VStack(alignment: .trailing, spacing: 1) {
                                Text(balance.formattedDisplay)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                Text("Remaining")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else if let _ = balanceError {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption2)
                            Text("Check balance")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    } else if userProfile.llmProvider.supportsBalanceCheck {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption2)
                            Text("Load balance")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 7, height: 7)
                            Text("Ready")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                #if os(iOS)
                .background(Color(.secondarySystemGroupedBackground))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .task(id: userProfile.preferredLLMProvider) {
            await fetchBalanceAsync()
        }
    }
    
    private func statColumn(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(iconColor)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func refreshBalance() {
        Task {
            await fetchBalanceAsync()
        }
    }
    
    @MainActor
    private func fetchBalanceAsync() async {
        let service = LLMServiceRegistry.shared.service(for: userProfile)
        guard service.supportsBalanceCheck else {
            balanceInfo = nil
            balanceError = nil
            return
        }
        
        isFetchingBalance = true
        balanceError = nil
        
        do {
            let balance = try await service.fetchBalance()
            self.balanceInfo = balance
            self.isFetchingBalance = false
        } catch {
            self.balanceError = error.localizedDescription
            self.isFetchingBalance = false
        }
    }
}
