import SwiftUI

/// Animated loading overlay with language learning tips while AI analysis runs.
public struct AnalysisLoadingOverlay: View {
    public let targetLanguage: TargetLanguage
    public let level: HSKLevel
    
    @State private var tipIndex: Int = 0
    @State private var isSpinning: Bool = false
    
    private let tips = [
        "Analyzing grammar structures and sentence patterns...",
        "Checking Chinese word order (Time-Subject-Location-Verb-Object)...",
        "Evaluating level-appropriate vocabulary...",
        "Crafting personalized feedback and vocabulary suggestions...",
        "Polishing a natural native phrasing version for you..."
    ]
    
    private let timer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()
    
    public init(targetLanguage: TargetLanguage, level: HSKLevel) {
        self.targetLanguage = targetLanguage
        self.level = level
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 5)
                        .frame(width: 64, height: 64)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(Angle(degrees: isSpinning ? 360 : 0))
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: isSpinning)
                    
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                
                VStack(spacing: 8) {
                    Text("Analyzing with DeepSeek")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(tips[tipIndex])
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(height: 36)
                        .animation(.easeInOut, value: tipIndex)
                }
            }
            .padding(28)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(32)
        }
        .onAppear {
            isSpinning = true
        }
        .onReceive(timer) { _ in
            tipIndex = (tipIndex + 1) % tips.count
        }
    }
}
