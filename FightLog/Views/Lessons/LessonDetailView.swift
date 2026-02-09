import SwiftUI
import SwiftData

struct LessonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var lesson: Lesson

    @State private var showingShareSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingEditSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: lesson.difficulty.icon)
                            .foregroundStyle(difficultyColor)
                        Text(lesson.difficulty.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Label("\(lesson.durationMinutes) min", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let notes = lesson.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Warmup
                if let warmup = lesson.warmupNotes, !warmup.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Warmup", systemImage: "flame.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)

                        Text(warmup)
                            .font(.body)
                    }
                }

                // Drills
                if !lesson.drills.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Drills", systemImage: "figure.boxing")
                            .font(.headline)

                        ForEach(Array(lesson.drills.enumerated()), id: \.element.id) { index, drill in
                            DrillCard(drill: drill, index: index + 1)
                        }
                    }
                }

                // Exercises
                if !lesson.exercises.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Exercises", systemImage: "dumbbell.fill")
                            .font(.headline)
                            .foregroundStyle(.green)

                        ForEach(Array(lesson.exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseCard(exercise: exercise, index: index + 1)
                        }
                    }
                }

                // Cooldown
                if let cooldown = lesson.cooldownNotes, !cooldown.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Cooldown", systemImage: "wind")
                            .font(.headline)
                            .foregroundStyle(.blue)

                        Text(cooldown)
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showingEditSheet = true
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
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(text: lesson.shareableText)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditLessonSheet(lesson: lesson)
        }
        .confirmationDialog("Delete Lesson?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(lesson)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var difficultyColor: Color {
        switch lesson.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

struct DrillCard: View {
    let drill: LessonDrill
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(index).")
                    .font(.headline)
                    .foregroundStyle(.orange)
                Text(drill.title)
                    .font(.headline)
            }

            if let combo = drill.comboNumbers {
                HStack {
                    Text("Combo:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(combo)
                        .font(.subheadline.monospaced().bold())
                }
            }

            HStack(spacing: 16) {
                if let reps = drill.reps {
                    Label("\(reps) reps", systemImage: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let rounds = drill.rounds {
                    Label("\(rounds) rounds", systemImage: "clock.badge.checkmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let time = drill.roundTimeSeconds {
                    let mins = time / 60
                    let secs = time % 60
                    Label("\(mins):\(String(format: "%02d", secs))", systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let notes = drill.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ExerciseCard: View {
    let exercise: ExerciseSlot
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: exercise.category.icon)
                    .foregroundStyle(.orange)
                Text("\(index). \(exercise.name)")
                    .font(.headline)
                Spacer()
                if let equipment = exercise.equipment {
                    Text(equipment)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 16) {
                if let sets = exercise.sets, let reps = exercise.reps {
                    Label("\(sets) × \(reps) reps", systemImage: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let duration = exercise.durationSeconds {
                    Label("\(duration / 60) min", systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let rest = exercise.restSeconds, rest > 0 {
                    Label("Rest: \(rest)s", systemImage: "pause.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        LessonDetailView(lesson: Lesson(
            title: "Boxing Basics",
            notes: "Great intro workout for beginners",
            difficulty: .beginner,
            durationMinutes: 30,
            warmupNotes: "3 rounds of jump rope, dynamic stretches",
            drills: [
                LessonDrill(title: "Jab Practice", comboNumbers: "1-1-1", reps: 50, notes: "Focus on full extension"),
                LessonDrill(title: "One-Two Combo", comboNumbers: "1-2", rounds: 3, roundTimeSeconds: 180, restTimeSeconds: 60),
                LessonDrill(title: "Basic Combo", comboNumbers: "1-2-3", rounds: 3, roundTimeSeconds: 180)
            ],
            cooldownNotes: "Light stretching, deep breathing"
        ))
    }
    .modelContainer(for: [Session.self, Technique.self, ProgressNote.self, Location.self, Combo.self, Lesson.self], inMemory: true)
}
