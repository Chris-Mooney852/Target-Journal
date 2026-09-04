import SwiftUI

public struct LanguageSelectionStep: View {
    @Binding var selectedLanguage: TargetLanguage
    
    public init(selectedLanguage: Binding<TargetLanguage>) {
        self._selectedLanguage = selectedLanguage
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Target Language")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Which language are you actively learning and practicing?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(TargetLanguage.allCases) { language in
                    Button(action: { selectedLanguage = language }) {
                        HStack(spacing: 14) {
                            Text(language.flagEmoji)
                                .font(.largeTitle)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(language.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(language.nativeName)
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
                        .padding(16)
                        .background(
                            selectedLanguage == language ?
                            Color.accentColor.opacity(0.12) :
                            Color.secondary.opacity(0.1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedLanguage == language ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Text("💡 Additional languages (Japanese, Spanish, French, Korean) will be available in future updates.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            
            Spacer()
        }
    }
}
