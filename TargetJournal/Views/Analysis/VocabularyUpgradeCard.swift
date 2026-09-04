import SwiftUI

/// Card showcasing level-appropriate vocabulary recommendations with Pinyin & example sentence.
public struct VocabularyUpgradeCard: View {
    public let item: VocabularyItem
    
    public init(item: VocabularyItem) {
        self.item = item
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.hanzi)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                if !item.pinyin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(item.pinyin)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(item.hskLevel)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
            }
            
            Text(item.english)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            if !item.exampleSentence.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Example:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(item.exampleSentence)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            
            if let note = item.contextNote, !note.isEmpty {
                Text("💡 \(note)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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
