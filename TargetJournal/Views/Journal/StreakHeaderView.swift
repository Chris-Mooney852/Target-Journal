import SwiftUI

/// Header displaying daily streak, word count stats, and active target language level.
public struct StreakHeaderView: View {
    public let userProfile: UserProfile
    public let totalEntries: Int
    public let totalCharacters: Int
    
    public init(userProfile: UserProfile, totalEntries: Int, totalCharacters: Int) {
        self.userProfile = userProfile
        self.totalEntries = totalEntries
        self.totalCharacters = totalCharacters
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Target Language & Level Card
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(userProfile.targetLanguage.flagEmoji)
                            .font(.title2)
                        Text(userProfile.targetLanguage.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    HSKBadge(level: userProfile.currentHSKLevel, style: .prominent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                #if os(iOS)
                .background(Color(.secondarySystemGroupedBackground))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                // Stats Card
                HStack(spacing: 16) {
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
                .padding(14)
                #if os(iOS)
                .background(Color(.secondarySystemGroupedBackground))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    private func statColumn(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(iconColor)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}
