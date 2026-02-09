import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProgressNote.timestamp, order: .reverse) private var notes: [ProgressNote]

    @State private var showingAddNote = false

    private var noteViewModel: NoteViewModel {
        NoteViewModel(modelContext: modelContext)
    }

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes Yet",
                        systemImage: "note.text",
                        description: Text("Capture your training insights and learnings")
                    )
                } else {
                    List {
                        ForEach(notes) { note in
                            NoteRow(note: note)
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                QuickNoteSheet()
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            noteViewModel.deleteNote(notes[index])
        }
    }
}

struct NoteRow: View {
    let note: ProgressNote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.content)
                .font(.body)
                .lineLimit(3)

            HStack {
                Text(formatDate(note.timestamp))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let session = note.session {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Label(session.sessionType.rawValue, systemImage: session.sessionType.icon)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.timeStyle = .short
            return "Yesterday at \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

#Preview {
    NoteListView()
        .modelContainer(for: [Session.self, Technique.self, ProgressNote.self], inMemory: true)
}
