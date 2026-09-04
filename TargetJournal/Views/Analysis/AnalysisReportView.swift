import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Comprehensive presentation of AI language critique, corrections, and level-up suggestions.
public struct AnalysisReportView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let report: AnalysisReport
    public let entry: JournalEntry
    
    @State private var selectedTab: Int = 0
    @State private var showCopiedAlert: Bool = false
    
    public init(report: AnalysisReport, entry: JournalEntry) {
        self.report = report
        self.entry = entry
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Score & Level Header
                scoreBanner
                
                // Fluency & Encouragement Cards
                feedbackCards
                
                // Segmented Tabs: Corrections, Vocabulary, Grammar, Polished
                tabSelector
                
                // Tab Content
                switch selectedTab {
                case 0:
                    correctionsSection
                case 1:
                    vocabularySection
                case 2:
                    grammarPatternsSection
                case 3:
                    polishedSection
                default:
                    EmptyView()
                }
            }
            .padding(16)
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        #else
        .background(Color(.windowBackgroundColor))
        #endif
        .navigationTitle("AI Tutor Feedback")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showCopiedAlert {
                Text("Polished text copied to clipboard!")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThickMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 6)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private var scoreBanner: some View {
        HStack(spacing: 16) {
            // Circular score gauge
            ZStack {
                Circle()
                    .stroke(Color.accentColor.opacity(0.2), lineWidth: 8)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: CGFloat(report.overallScore) / 100.0)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(report.overallScore)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("/ 100")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Evaluated Level:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if let level = HSKLevel(rawValue: report.evaluatedLevel) {
                        HSKBadge(level: level, style: .standard)
                    } else {
                        Text(report.evaluatedLevel)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                Text("Analyzed by \(report.providerName) (\(report.modelUsed))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        #if os(iOS)
        .background(Color(.secondarySystemGroupedBackground))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var feedbackCards: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !report.fluencySummary.isEmpty {
                StatusBanner(
                    icon: "text.magnifyingglass",
                    title: "Fluency Assessment",
                    message: report.fluencySummary,
                    color: .blue
                )
            }
            
            if !report.encouragingFeedback.isEmpty {
                StatusBanner(
                    icon: "hand.thumbsup.fill",
                    title: "Tutor's Note",
                    message: report.encouragingFeedback,
                    color: .green
                )
            }
        }
    }
    
    private var tabSelector: some View {
        Picker("Report Section", selection: $selectedTab) {
            Text("Corrections (\(report.corrections.count))").tag(0)
            Text("Vocab (\(report.vocabularyRecommendations.count))").tag(1)
            Text("Patterns (\(report.grammarPatterns.count))").tag(2)
            Text("Polished").tag(3)
        }
        .pickerStyle(.segmented)
    }
    
    private var correctionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if report.corrections.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text("No errors found! Excellent work for your level.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(report.corrections) { item in
                    CorrectionCardView(correction: item)
                }
            }
        }
    }
    
    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended words to expand your Chinese:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if report.vocabularyRecommendations.isEmpty {
                Text("No vocabulary recommendations available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(report.vocabularyRecommendations) { item in
                    VocabularyUpgradeCard(item: item)
                }
            }
        }
    }
    
    private var grammarPatternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if report.grammarPatterns.isEmpty {
                Text("No grammar patterns highlighted in this note.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(report.grammarPatterns) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.pattern)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Text(item.level)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        
                        Text(item.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
        }
    }
    
    private var polishedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DiffComparisonView(
                original: entry.rawMarkdown,
                polished: report.polishedVersion.isEmpty ? entry.rawMarkdown : report.polishedVersion
            )
            
            if !report.polishedVersion.isEmpty {
                Button(action: copyPolishedText) {
                    Label("Copy Polished Version", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
            }
        }
    }
    
    private func copyPolishedText() {
        #if canImport(UIKit)
        UIPasteboard.general.string = report.polishedVersion
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(report.polishedVersion, forType: .string)
        #endif
        
        withAnimation {
            showCopiedAlert = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showCopiedAlert = false
            }
        }
    }
}
