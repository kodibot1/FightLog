import SwiftUI
import SwiftData

struct QuickNoteSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]

    @State private var content: String = ""
    @State private var linkedSession: Session?
    @State private var showSessionPicker = false

    @FocusState private var isTextFieldFocused: Bool

    private var noteViewModel: NoteViewModel {
        NoteViewModel(modelContext: modelContext)
    }

    private var recentSession: Session? {
        // Only suggest linking if session was within last 2 hours
        guard let recent = sessions.first else { return nil }
        let twoHoursAgo = Date().addingTimeInterval(-2 * 60 * 60)
        return recent.timestamp > twoHoursAgo ? recent : nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Text Input
                TextField("What did you learn? Any insights?", text: $content, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .lineLimit(5...12)
                    .focused($isTextFieldFocused)

                // Link to Session (optional)
                if let recent = recentSession {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Link to session")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button {
                            if linkedSession == recent {
                                linkedSession = nil
                            } else {
                                linkedSession = recent
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            HStack {
                                Image(systemName: recent.sessionType.icon)
                                    .foregroundStyle(.orange)
                                Text(recent.sessionType.rawValue)
                                Text("•")
                                    .foregroundStyle(.secondary)
                                Text(formatTime(recent.timestamp))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Image(systemName: linkedSession == recent ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(linkedSession == recent ? .orange : .secondary)
                            }
                            .padding()
                            .background(linkedSession == recent ? Color.orange.opacity(0.1) : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Quick Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .font(.body.bold())
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }

    private func saveNote() {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        _ = noteViewModel.createNote(content: content, session: linkedSession)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    QuickNoteSheet()
        .modelContainer(for: [Session.self, Technique.self, ProgressNote.self], inMemory: true)
}
