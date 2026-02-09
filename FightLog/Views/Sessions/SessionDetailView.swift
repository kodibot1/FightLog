import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var session: Session
    @Query private var allTechniques: [Technique]

    @State private var isEditing = false
    @State private var editedType: SessionType
    @State private var editedDuration: Int
    @State private var editedIntensity: Intensity?
    @State private var editedNotes: String
    @State private var editedTechniques: Set<Technique>
    @State private var showingDeleteConfirmation = false

    private var sessionViewModel: SessionViewModel {
        SessionViewModel(modelContext: modelContext)
    }

    init(session: Session) {
        self.session = session
        _editedType = State(initialValue: session.sessionType)
        _editedDuration = State(initialValue: session.duration)
        _editedIntensity = State(initialValue: session.intensity)
        _editedNotes = State(initialValue: session.notes ?? "")
        _editedTechniques = State(initialValue: Set(session.techniques))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 12) {
                    Image(systemName: session.sessionType.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text(session.sessionType.rawValue)
                        .font(.title.bold())

                    HStack(spacing: 16) {
                        Label("\(session.duration) min", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let intensity = session.intensity {
                            Label(intensity.rawValue, systemImage: "flame")
                                .font(.subheadline)
                                .foregroundStyle(intensityColor(intensity))
                        }
                    }

                    Text(formatDate(session.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Techniques
                if !session.techniques.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Techniques")
                            .font(.headline)
                            .padding(.horizontal)

                        FlowLayout(spacing: 8) {
                            ForEach(session.techniques) { technique in
                                Text(technique.name)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundStyle(.orange)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Notes
                if let notes = session.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)

                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                // Linked Notes
                if !session.progressNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Linked Notes")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(session.progressNotes) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.content)
                                    .font(.body)
                                Text(formatTime(note.timestamp))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isEditing = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditSessionSheet(
                session: session,
                editedType: $editedType,
                editedDuration: $editedDuration,
                editedIntensity: $editedIntensity,
                editedNotes: $editedNotes,
                editedTechniques: $editedTechniques,
                allTechniques: allTechniques
            )
        }
        .confirmationDialog("Delete Session?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                sessionViewModel.deleteSession(session)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func intensityColor(_ intensity: Intensity) -> Color {
        switch intensity {
        case .light: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EditSessionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let session: Session
    @Binding var editedType: SessionType
    @Binding var editedDuration: Int
    @Binding var editedIntensity: Intensity?
    @Binding var editedNotes: String
    @Binding var editedTechniques: Set<Technique>
    let allTechniques: [Technique]

    private var sessionViewModel: SessionViewModel {
        SessionViewModel(modelContext: modelContext)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Session Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Type")
                            .font(.headline)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(SessionType.allCases) { type in
                                SessionTypeButton(
                                    type: type,
                                    isSelected: editedType == type
                                ) {
                                    editedType = type
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Duration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Duration")
                            .font(.headline)

                        HStack(spacing: 12) {
                            ForEach([15, 30, 45, 60, 90], id: \.self) { mins in
                                DurationButton(
                                    minutes: mins,
                                    isSelected: editedDuration == mins
                                ) {
                                    editedDuration = mins
                                }
                            }
                        }

                        Stepper("Custom: \(editedDuration) min", value: $editedDuration, in: 5...180, step: 5)
                    }
                    .padding(.horizontal)

                    // Intensity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Intensity")
                            .font(.headline)

                        HStack(spacing: 12) {
                            ForEach(Intensity.allCases) { intensity in
                                IntensityButton(
                                    intensity: intensity,
                                    isSelected: editedIntensity == intensity
                                ) {
                                    if editedIntensity == intensity {
                                        editedIntensity = nil
                                    } else {
                                        editedIntensity = intensity
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Techniques
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Techniques")
                            .font(.headline)

                        NavigationLink {
                            TechniquePickerView(selectedTechniques: $editedTechniques)
                        } label: {
                            HStack {
                                if editedTechniques.isEmpty {
                                    Text("Select techniques")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("\(editedTechniques.count) selected")
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        if !editedTechniques.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(Array(editedTechniques)) { technique in
                                    TechniqueChip(
                                        technique: technique,
                                        isSelected: true
                                    ) {
                                        editedTechniques.remove(technique)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)

                        TextField("Session notes...", text: $editedNotes, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .lineLimit(3...6)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Reset to original values
                        editedType = session.sessionType
                        editedDuration = session.duration
                        editedIntensity = session.intensity
                        editedNotes = session.notes ?? ""
                        editedTechniques = Set(session.techniques)
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(.body.bold())
                }
            }
        }
    }

    private func saveChanges() {
        sessionViewModel.updateSession(
            session,
            sessionType: editedType,
            duration: editedDuration,
            intensity: editedIntensity,
            notes: editedNotes,
            techniques: Array(editedTechniques)
        )
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: Session(sessionType: .sparring, duration: 30, intensity: .moderate))
    }
    .modelContainer(for: [Session.self, Technique.self, ProgressNote.self], inMemory: true)
}
