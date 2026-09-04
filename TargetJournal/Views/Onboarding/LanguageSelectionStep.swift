import SwiftUI

public struct LanguageSelectionStep: View {
    @Binding var selectedLanguage: TargetLanguage
    
    public init(selectedLanguage: Binding<TargetLanguage>) {
        self._selectedLanguage = selectedLanguage
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Select Target Language")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Which language are you actively learning and practicing?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(TargetLanguage.allCases) { language in
                        Button(action: { selectedLanguage = language }) {
                            HStack(spacing: 14) {
                                Text(language.flagEmoji)
                                    .font(.title)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(language.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("\(language.nativeName) • \(language.levelSystemName)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedLanguage == language {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding(14)
                            .background(
                                selectedLanguage == language ?
                                Color.accentColor.opacity(0.12) :
                                Color.secondary.opacity(0.1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedLanguage == language ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
