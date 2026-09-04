import SwiftUI

/// Card displaying an individual grammar/vocabulary correction with explanation and badge.
public struct CorrectionCardView: View {
    public let correction: GrammarCorrection
    @State private var isExpanded: Bool = true
    
    public init(correction: GrammarCorrection) {
        self.correction = correction
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with category badge and rule tag
            HStack {
                Text(correction.category.rawValue)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(categoryColor.opacity(0.15))
                    .foregroundStyle(categoryColor)
                    .clipShape(Capsule())
                
                if let tag = correction.ruleTag, !tag.isEmpty {
                    Text(tag)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Diff Side-by-Side or Staggered
            VStack(alignment: .leading, spacing: 6) {
                // Original
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 2)
                    
                    Text(correction.original)
                        .font(.body)
                        .strikethrough()
                        .foregroundStyle(.secondary)
                }
                
                // Corrected
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .padding(.top, 2)
                    
                    Text(correction.corrected)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }
            
            // Explanation
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                        .padding(.vertical, 2)
                    
                    Text(correction.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
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
    
    private var categoryColor: Color {
        switch correction.category {
        case .grammar: return .blue
        case .vocabulary: return .purple
        case .wordOrder: return .orange
        case .toneAndNaturalness: return .teal
        case .punctuation: return .gray
        case .measureWord: return .indigo
        }
    }
}
