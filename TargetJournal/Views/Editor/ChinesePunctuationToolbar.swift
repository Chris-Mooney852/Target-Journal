import SwiftUI

/// Toolbar row providing one-tap access to Chinese full-width punctuation and brackets.
public struct ChinesePunctuationToolbar: View {
    public var onInsert: (String) -> Void
    
    private let punctuations = [
        ("，", "Comma"),
        ("。", "Period"),
        ("！", "Exclamation"),
        ("？", "Question"),
        ("、", "Enumeration"),
        ("：", "Colon"),
        ("；", "Semicolon"),
        ("“ ”", "Quotes"),
        ("「 」", "Corner Quotes"),
        ("《 》", "Book Title"),
        ("——", "Dash"),
        ("……", "Ellipsis")
    ]
    
    public init(onInsert: @escaping (String) -> Void) {
        self.onInsert = onInsert
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(punctuations, id: \.0) { item in
                    Button(action: {
                        if item.0 == "“ ”" {
                            onInsert("“”")
                        } else if item.0 == "「 」" {
                            onInsert("「」")
                        } else if item.0 == "《 》" {
                            onInsert("《》")
                        } else {
                            onInsert(item.0)
                        }
                    }) {
                        Text(item.0)
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .frame(minWidth: 32, minHeight: 32)
                            .padding(.horizontal, 6)
                            .background(Color.secondary.opacity(0.15))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
}
