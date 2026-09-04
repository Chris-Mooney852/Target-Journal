import SwiftUI
import SwiftData

/// Main screen displaying the journal timeline, search, stats header, and entry creation.
public struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    
    var userProfile: UserProfile
    
    @State private var searchText: String = ""
    @State private var activeEntryToEdit: JournalEntry?
    @State private var showSettingsSheet: Bool = false
    
    public init(userProfile: UserProfile) {
        self.userProfile = userProfile
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    if filteredEntries.isEmpty {
                        emptyPlaceholder
                    } else {
                        ForEach(filteredEntries) { entry in
                            NavigationLink(destination: EntryDetailView(entry: entry, userProfile: userProfile)) {
                                JournalRowView(entry: entry)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteEntry(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 14) {
                        StreakHeaderView(
                            userProfile: userProfile,
                            totalEntries: entries.count,
                            totalCharacters: totalCharactersWritten
                        )
                        
                        Text("Journal Entries")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    .textCase(nil)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.sidebar)
            #endif
            .searchable(text: $searchText, prompt: "Search notes or Chinese characters...")
            .navigationTitle("TargetJournal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: createNewEntry) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("New Note")
                        }
                        .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            #if os(iOS)
            .fullScreenCover(item: $activeEntryToEdit) { entry in
                MarkdownEditorView(entry: entry, userProfile: userProfile)
            }
            #else
            .sheet(item: $activeEntryToEdit) { entry in
                MarkdownEditorView(entry: entry, userProfile: userProfile)
            }
            #endif
            .sheet(isPresented: $showSettingsSheet) {
                NavigationStack {
                    SettingsView(userProfile: userProfile)
                }
            }
        }
    }
    
    private var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.rawMarkdown.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var totalCharactersWritten: Int {
        entries.reduce(0) { $0 + $1.characterCount }
    }
    
    private var emptyPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 16)
            
            Text("Start Your \(userProfile.targetLanguage.displayName) Journey")
                .font(.headline)
            
            Text("Write daily journal notes to build vocabulary, refine sentence grammar, and receive personalized tutor feedback.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button("Write Today's Note", action: createNewEntry)
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        #if os(iOS)
        .listRowBackground(Color.clear)
        #endif
    }
    
    private func createNewEntry() {
        let now = Date()
        let newEntry = JournalEntry(
            title: JournalEntry.formattedDateTitle(for: now),
            rawMarkdown: "",
            date: now,
            targetLanguage: userProfile.targetLanguage,
            recordedHSKLevel: userProfile.currentHSKLevel
        )
        modelContext.insert(newEntry)
        try? modelContext.save()
        activeEntryToEdit = newEntry
    }
    
    private func deleteEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }
}
