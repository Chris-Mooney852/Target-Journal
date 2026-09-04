import SwiftUI

/// Timeline row representing a single journal entry.
public struct JournalRowView: View {
    public let entry: JournalEntry
    
    public init(entry: JournalEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text(entry.title.isEmpty ? JournalEntry.formattedDateTitle(for: entry.date) : entry.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                HSKBadge(level: entry.recordedHSKLevel, style: .compact)
            }
            
            // Content preview snippet
            Text(snippetText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .lineSpacing(3)
            
            // Meta footer: Date, Char count, AI analysis status
            HStack(spacing: 8) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text("\(entry.characterCount) characters")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if let latest = entry.latestAnalysis {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("Score \(latest.overallScore)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var snippetText: String {
        let cleaned = entry.rawMarkdown
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: ">", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? "No content..." : cleaned
    }
}
