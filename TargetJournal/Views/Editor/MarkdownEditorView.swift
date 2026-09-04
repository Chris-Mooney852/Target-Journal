import SwiftUI
import SwiftData

/// Dual-mode Markdown Editor: Raw Typing and WYSIWYG Preview with instant AI Analysis trigger.
public struct MarkdownEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var entry: JournalEntry
    var userProfile: UserProfile
    
    @State private var selectedTab: EditorTab = .edit
    @State private var showChinesePunctuation: Bool = false
    @State private var isAnalyzing: Bool = false
    @State private var activeAnalysisReport: AnalysisReport?
    @State private var showAnalysisSheet: Bool = false
    @State private var errorMessage: String?
    @State private var showErrorAlert: Bool = false
    
    @FocusState private var isContentFocused: Bool
    @FocusState private var isTitleFocused: Bool
    
    public enum EditorTab: String, CaseIterable, Identifiable {
        case edit = "Write"
        case preview = "Preview"
        
        public var id: String { rawValue }
    }
    
    public init(entry: JournalEntry, userProfile: UserProfile) {
        self.entry = entry
        self.userProfile = userProfile
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode Switcher Header
                HStack {
                    Picker("Editor Mode", selection: $selectedTab) {
                        ForEach(EditorTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                    
                    Spacer()
                    
                    HSKBadge(level: entry.recordedHSKLevel, style: .compact)
                    
                    Text("\(entry.characterCount) 字")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                #if os(iOS)
                .background(Color(.secondarySystemBackground))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                
                Divider()
                
                // Content area
                if selectedTab == .edit {
                    rawEditorView
                } else {
                    WYSIWYGPreviewView(
                        title: entry.title,
                        markdown: entry.rawMarkdown,
                        targetLanguage: entry.targetLanguage,
                        level: entry.recordedHSKLevel,
                        date: entry.date
                    )
                }
                
                // Keyboard Accessory Bar when editing
                if selectedTab == .edit && (isContentFocused || isTitleFocused) {
                    MarkdownAccessoryBar(
                        text: $entry.rawMarkdown,
                        showChinesePunctuation: $showChinesePunctuation,
                        onDismissKeyboard: {
                            isContentFocused = false
                            isTitleFocused = false
                        }
                    )
                }
            }
            .navigationTitle(entry.date.formatted(date: .abbreviated, time: .omitted))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        saveAndDismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: triggerAnalysis) {
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                            Text("Analyze")
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(entry.rawMarkdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnalyzing)
                }
            }
            .overlay {
                if isAnalyzing {
                    AnalysisLoadingOverlay(targetLanguage: entry.targetLanguage, level: entry.recordedHSKLevel)
                }
            }
            .sheet(isPresented: $showAnalysisSheet) {
                if let report = activeAnalysisReport {
                    NavigationStack {
                        AnalysisReportView(report: report, entry: entry)
                    }
                }
            }
            .alert("Analysis Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
        }
    }
    
    private var rawEditorView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Title (e.g. 今天的天气 / Today's Thoughts)", text: $entry.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .focused($isTitleFocused)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                Divider()
                    .padding(.horizontal, 16)
                
                ZStack(alignment: .topLeading) {
                    if entry.rawMarkdown.isEmpty {
                        Text("Write your journal in \(entry.targetLanguage.displayName) (\(entry.targetLanguage.nativeName))...\n\nTips:\n• Use Markdown headers (#, ##)\n• Bullet points (- item)\n• Chinese punctuation button below")
                            .font(.body)
                            .foregroundStyle(.secondary.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $entry.rawMarkdown)
                        .font(.system(.body, design: .default))
                        .lineSpacing(6)
                        .focused($isContentFocused)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 350)
                }
            }
        }
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
        .onTapGesture {
            if !isContentFocused && !isTitleFocused {
                isContentFocused = true
            }
        }
    }
    
    private func saveAndDismiss() {
        entry.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }
    
    private func triggerAnalysis() {
        isContentFocused = false
        isTitleFocused = false
        isAnalyzing = true
        
        let request = AnalysisRequest(
            journalContent: entry.rawMarkdown,
            title: entry.title,
            targetLanguage: entry.targetLanguage,
            userLevel: entry.recordedHSKLevel,
            nativeLanguage: userProfile.nativeLanguage
        )
        
        let service = LLMServiceRegistry.shared.service(for: userProfile)
        
        Task {
            do {
                let response = try await service.analyze(request: request)
                
                await MainActor.run {
                    let report = AnalysisReport(
                        createdAt: Date(),
                        providerName: service.providerName,
                        modelUsed: userProfile.deepSeekModel,
                        evaluatedLevel: entry.recordedHSKLevel.rawValue,
                        overallScore: response.overallScore,
                        fluencySummary: response.fluencySummary,
                        encouragingFeedback: response.encouragingFeedback,
                        corrections: response.corrections.map {
                            GrammarCorrection(
                                original: $0.original,
                                corrected: $0.corrected,
                                explanation: $0.explanation,
                                category: CorrectionCategory(rawValue: $0.category) ?? .grammar,
                                ruleTag: $0.ruleTag
                            )
                        },
                        vocabularyRecommendations: response.vocabularyRecommendations.map {
                            VocabularyItem(
                                hanzi: $0.hanzi,
                                pinyin: $0.pinyin,
                                english: $0.english,
                                hskLevel: $0.hskLevel,
                                exampleSentence: $0.exampleSentence,
                                contextNote: $0.contextNote
                            )
                        },
                        grammarPatterns: response.grammarPatterns.map {
                            GrammarPatternHighlight(
                                pattern: $0.pattern,
                                explanation: $0.explanation,
                                level: $0.level
                            )
                        },
                        polishedVersion: response.polishedVersion
                    )
                    
                    report.journalEntry = entry
                    entry.analysisReports.append(report)
                    modelContext.insert(report)
                    try? modelContext.save()
                    
                    self.activeAnalysisReport = report
                    self.isAnalyzing = false
                    self.showAnalysisSheet = true
                }
            } catch {
                await MainActor.run {
                    self.isAnalyzing = false
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            }
        }
    }
}
