import SwiftUI
import SwiftData

/// Detailed view for a journal entry with options to edit or view AI analysis history.
public struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: JournalEntry
    var userProfile: UserProfile
    
    @State private var showEditorSheet: Bool = false
    @State private var selectedReport: AnalysisReport?
    
    public init(entry: JournalEntry, userProfile: UserProfile) {
        self.entry = entry
        self.userProfile = userProfile
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        HSKBadge(level: entry.recordedHSKLevel, style: .standard)
                        Spacer()
                        Text(entry.date.formatted(date: .complete, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !entry.title.isEmpty {
                        Text(entry.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                
                Divider()
                
                // Formatted Markdown Content
                WYSIWYGPreviewView(
                    title: "",
                    markdown: entry.rawMarkdown,
                    targetLanguage: entry.targetLanguage,
                    level: entry.recordedHSKLevel,
                    date: entry.date,
                    isScrollable: false
                )
                
                // AI Feedback Section
                if let latest = entry.latestAnalysis {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("AI Tutor Analysis", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Text("Score: \(latest.overallScore)/100")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        
                        Button(action: { selectedReport = latest }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(latest.fluencySummary.isEmpty ? "View detailed critique" : latest.fluencySummary)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                    
                                    Text("\(latest.corrections.count) corrections • \(latest.vocabularyRecommendations.count) vocabulary suggestions")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(14)
                            #if os(iOS)
                            .background(Color(.secondarySystemGroupedBackground))
                            #else
                            .background(Color(.controlBackgroundColor))
                            #endif
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 10)
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showEditorSheet = true }) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showEditorSheet) {
            MarkdownEditorView(entry: entry, userProfile: userProfile)
        }
        #else
        .sheet(isPresented: $showEditorSheet) {
            MarkdownEditorView(entry: entry, userProfile: userProfile)
        }
        #endif
        .sheet(item: $selectedReport) { report in
            NavigationStack {
                AnalysisReportView(report: report, entry: entry)
            }
        }
    }
}
