import SwiftUI

public struct LevelSelectionStep: View {
    @Binding var selectedLevel: HSKLevel
    let language: TargetLanguage
    
    public init(selectedLevel: Binding<HSKLevel>, language: TargetLanguage) {
        self._selectedLevel = selectedLevel
        self.language = language
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Current Level")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Select your current proficiency in \(language.levelSystemName). The AI tutor uses this to calibrate feedback and vocabulary recommendations.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(language.supportedLevels) { level in
                        Button(action: { selectedLevel = level }) {
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(Color(hex: level.badgeColorHex))
                                    .frame(width: 12, height: 12)
                                    .padding(.top, 4)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(level.title)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.primary)
                                        
                                        Text("• \(level.proficiencyTier)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(level.vocabularyTarget)
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.secondary.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                    
                                    Text(level.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                if selectedLevel == level {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding(14)
                            .background(
                                selectedLevel == level ?
                                Color.accentColor.opacity(0.12) :
                                Color.secondary.opacity(0.1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedLevel == level ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .onAppear {
            if !language.supportedLevels.contains(selectedLevel) {
                selectedLevel = language.defaultLevel
            }
        }
        .onChange(of: language) { _, newLanguage in
            if !newLanguage.supportedLevels.contains(selectedLevel) {
                selectedLevel = newLanguage.defaultLevel
            }
        }
    }
}
