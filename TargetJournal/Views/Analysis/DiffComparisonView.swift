import SwiftUI

/// Visual diff comparison showing the user's original entry alongside the polished native version.
public struct DiffComparisonView: View {
    public let original: String
    public let polished: String
    @State private var selectedSegment: Int = 0 // 0: Side by Side, 1: Polished Only, 2: Original Only
    
    public init(original: String, polished: String) {
        self.original = original
        self.polished = polished
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("View Mode", selection: $selectedSegment) {
                Text("Side-by-Side").tag(0)
                Text("Polished").tag(1)
                Text("Original").tag(2)
            }
            .pickerStyle(.segmented)
            
            if selectedSegment == 0 {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Your Draft", systemImage: "pencil")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Text(original)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Polished Native Version", systemImage: "sparkles")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                        
                        Text(polished)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            } else if selectedSegment == 1 {
                Text(polished)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundStyle(.primary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Text(original)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundStyle(.secondary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
