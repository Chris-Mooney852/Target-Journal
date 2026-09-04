import SwiftUI

/// Accessory toolbar for formatting Markdown and inserting Chinese characters.
public struct MarkdownAccessoryBar: View {
    @Binding var text: String
    @Binding var showChinesePunctuation: Bool
    var onDismissKeyboard: () -> Void
    
    public init(
        text: Binding<String>,
        showChinesePunctuation: Binding<Bool>,
        onDismissKeyboard: @escaping () -> Void
    ) {
        self._text = text
        self._showChinesePunctuation = showChinesePunctuation
        self.onDismissKeyboard = onDismissKeyboard
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if showChinesePunctuation {
                ChinesePunctuationToolbar { symbol in
                    insertText(symbol)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                Divider()
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showChinesePunctuation.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text("标点")
                            .font(.caption)
                            .fontWeight(.bold)
                        Image(systemName: showChinesePunctuation ? "chevron.down" : "chevron.up")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(showChinesePunctuation ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.15))
                    .foregroundStyle(showChinesePunctuation ? Color.accentColor : Color.primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Divider().frame(height: 18)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        toolbarButton(icon: "bold", title: "Bold") {
                            wrapSelectedOrAppend(prefix: "**", suffix: "**", placeholder: "粗体")
                        }
                        
                        toolbarButton(icon: "italic", title: "Italic") {
                            wrapSelectedOrAppend(prefix: "*", suffix: "*", placeholder: "斜体")
                        }
                        
                        toolbarButton(icon: "number", title: "Heading 1") {
                            insertLinePrefix("# ")
                        }
                        
                        toolbarButton(icon: "number.square", title: "Heading 2") {
                            insertLinePrefix("## ")
                        }
                        
                        toolbarButton(icon: "list.bullet", title: "Bullet List") {
                            insertLinePrefix("- ")
                        }
                        
                        toolbarButton(icon: "list.number", title: "Numbered List") {
                            insertLinePrefix("1. ")
                        }
                        
                        toolbarButton(icon: "checkmark.square", title: "Checklist") {
                            insertLinePrefix("- [ ] ")
                        }
                        
                        toolbarButton(icon: "text.quote", title: "Quote") {
                            insertLinePrefix("> ")
                        }
                        
                        toolbarButton(icon: "link", title: "Link") {
                            wrapSelectedOrAppend(prefix: "[", suffix: "](https://)", placeholder: "链接文字")
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                Spacer()
                
                Button(action: onDismissKeyboard) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }
    
    private func toolbarButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.body)
                .frame(width: 28, height: 28)
                .foregroundStyle(.primary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
    
    private func insertText(_ string: String) {
        text.append(string)
    }
    
    private func wrapSelectedOrAppend(prefix: String, suffix: String, placeholder: String) {
        text.append("\(prefix)\(placeholder)\(suffix)")
    }
    
    private func insertLinePrefix(_ prefix: String) {
        if text.isEmpty || text.hasSuffix("\n") {
            text.append(prefix)
        } else {
            text.append("\n\(prefix)")
        }
    }
}
