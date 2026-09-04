import SwiftUI

/// Formatted WYSIWYG / Markdown preview with specialized Chinese typography.
public struct WYSIWYGPreviewView: View {
    public let title: String
    public let markdown: String
    public let targetLanguage: TargetLanguage
    public let level: HSKLevel
    public let date: Date
    public let isScrollable: Bool
    
    public init(
        title: String = "",
        markdown: String,
        targetLanguage: TargetLanguage = .simplifiedChinese,
        level: HSKLevel = .hsk1,
        date: Date = Date(),
        isScrollable: Bool = true
    ) {
        self.title = title
        self.markdown = markdown
        self.targetLanguage = targetLanguage
        self.level = level
        self.date = date
        self.isScrollable = isScrollable
    }
    
    public var body: some View {
        if isScrollable {
            ScrollView {
                content
                    .padding(20)
            }
            #if os(iOS)
            .background(Color(.systemGroupedBackground))
            #else
            .background(Color(.windowBackgroundColor))
            #endif
        } else {
            content
        }
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !title.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Divider()
                }
            }
            
            // Formatted Content
            if markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "pencil.and.scribble")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("No notes written yet. Switch to Write mode to start journaling in \(targetLanguage.displayName).")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                MarkdownContentRenderer(markdown: markdown)
            }
        }
    }
}

/// Renders markdown blocks with custom styling for Chinese text.
struct MarkdownContentRenderer: View {
    let markdown: String
    
    var body: some View {
        let lines = markdown.components(separatedBy: "\n")
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                renderLine(line)
            }
        }
    }
    
    @ViewBuilder
    private func renderLine(_ line: String) -> some View {
        if line.hasPrefix("# ") {
            Text(LocalizedStringKey(String(line.dropFirst(2))))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.top, 6)
        } else if line.hasPrefix("## ") {
            Text(LocalizedStringKey(String(line.dropFirst(3))))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.top, 4)
        } else if line.hasPrefix("### ") {
            Text(LocalizedStringKey(String(line.dropFirst(4))))
                .font(.headline)
                .foregroundStyle(.primary)
        } else if line.hasPrefix("> ") {
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor)
                    .frame(width: 4)
                Text(LocalizedStringKey(String(line.dropFirst(2))))
                    .font(.body)
                    .italic()
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        } else if line.hasPrefix("- [ ] ") {
            HStack(spacing: 8) {
                Image(systemName: "square")
                    .foregroundStyle(.secondary)
                Text(LocalizedStringKey(String(line.dropFirst(6))))
                    .font(.body)
            }
        } else if line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ") {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.square.fill")
                    .foregroundStyle(Color.accentColor)
                Text(LocalizedStringKey(String(line.dropFirst(6))))
                    .font(.body)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            }
        } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
                Text(LocalizedStringKey(String(line.dropFirst(2))))
                    .font(.system(.body, design: .default))
                    .lineSpacing(6)
            }
        } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
            Spacer().frame(height: 6)
        } else {
            Text(LocalizedStringKey(line))
                .font(.system(.body, design: .default))
                .lineSpacing(8)
                .foregroundStyle(.primary)
        }
    }
}
