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
}
