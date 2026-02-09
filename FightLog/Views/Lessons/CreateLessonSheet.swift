import SwiftUI
import SwiftData

struct CreateLessonSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Combo.useCount, order: .reverse) private var combos: [Combo]

    @State private var title = ""
    @State private var notes = ""
    @State private var difficulty: LessonDifficulty = .beginner
    @State private var durationMinutes = 30
    @State private var warmupNotes = ""
    @State private var cooldownNotes = ""
    @State private var drills: [LessonDrill] = []
    @State private var exercises: [ExerciseSlot] = []
    @State private var showingAddDrill = false
    @State private var showingAddExercise = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Lesson Info") {
                    TextField("Title (e.g., Boxing Fundamentals)", text: $title)

                    TextField("Description", text: $notes, axis: .vertical)
                        .lineLimit(2...4)

                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(LessonDifficulty.allCases) { level in
                            Label(level.rawValue, systemImage: level.icon)
                                .tag(level)
                        }
                    }

                    Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 10...120, step: 5)
                }

                Section("Warmup") {
                    TextField("Warmup notes (e.g., 3 rounds jump rope)", text: $warmupNotes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    ForEach(drills) { drill in
                        DrillRowEditable(drill: drill)
                    }
                    .onDelete(perform: deleteDrills)
                    .onMove(perform: moveDrills)

                    Button {
                        showingAddDrill = true
                    } label: {
                        Label("Add Drill", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Drills")
                } footer: {
                    Text("Add the drills/exercises that make up this workout")
                }

                Section {
                    ForEach(exercises) { exercise in
                        ExerciseRowEditable(exercise: exercise)
                    }
                    .onDelete { exercises.remove(atOffsets: $0) }
                    .onMove { exercises.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        showingAddExercise = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Exercises")
                } footer: {
                    Text("Add warmup, strength, conditioning exercises")
                }

                Section("Cooldown") {
                    TextField("Cooldown notes (e.g., stretching)", text: $cooldownNotes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Create Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createLesson()
                    }
                    .font(.body.bold())
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showingAddDrill) {
                AddDrillSheet(drills: $drills, combos: combos)
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseSheet(exercises: $exercises)
            }
        }
    }

    private func deleteDrills(at offsets: IndexSet) {
        drills.remove(atOffsets: offsets)
    }

    private func moveDrills(from source: IndexSet, to destination: Int) {
        drills.move(fromOffsets: source, toOffset: destination)
    }

    private func createLesson() {
        let lesson = Lesson(
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes,
            difficulty: difficulty,
            durationMinutes: durationMinutes,
            warmupNotes: warmupNotes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : warmupNotes,
            drills: drills,
            exercises: exercises,
            cooldownNotes: cooldownNotes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : cooldownNotes
        )
        modelContext.insert(lesson)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

struct DrillRowEditable: View {
    let drill: LessonDrill

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(drill.title)
                .font(.body)

            HStack {
                if let combo = drill.comboNumbers {
                    Text(combo)
                        .font(.caption.monospaced())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                }

                if let reps = drill.reps {
                    Text("\(reps) reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let rounds = drill.rounds {
                    Text("\(rounds) rounds")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct ExerciseRowEditable: View {
    let exercise: ExerciseSlot

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: exercise.category.icon)
                .foregroundStyle(.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.body)

                HStack(spacing: 6) {
                    if let sets = exercise.sets, let reps = exercise.reps {
                        Text("\(sets)×\(reps) reps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let duration = exercise.durationSeconds {
                        Text("\(duration / 60) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let equipment = exercise.equipment {
                        Text(equipment)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

struct AddDrillSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var drills: [LessonDrill]
    let combos: [Combo]

    @State private var title = ""
    @State private var selectedCombo: Combo?
    @State private var customCombo = ""
    @State private var useReps = true
    @State private var reps = 20
    @State private var rounds = 3
    @State private var roundTimeSeconds = 180
    @State private var restTimeSeconds = 60
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Drill Info") {
                    TextField("Title (e.g., Jab Practice)", text: $title)

                    TextField("Notes/Tips", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Combo (Optional)") {
                    if !combos.isEmpty {
                        Picker("Select Combo", selection: $selectedCombo) {
                            Text("None").tag(nil as Combo?)
                            ForEach(combos.prefix(10)) { combo in
                                Text(combo.displayName).tag(combo as Combo?)
                            }
                        }
                    }

                    TextField("Or enter custom (e.g., 1-2-3-2)", text: $customCombo)
                        .font(.body.monospaced())
                }

                Section("Structure") {
                    Picker("Type", selection: $useReps) {
                        Text("Reps").tag(true)
                        Text("Rounds").tag(false)
                    }
                    .pickerStyle(.segmented)

                    if useReps {
                        Stepper("Reps: \(reps)", value: $reps, in: 5...200, step: 5)
                    } else {
                        Stepper("Rounds: \(rounds)", value: $rounds, in: 1...12)
                        Stepper("Round Time: \(roundTimeSeconds/60):\(String(format: "%02d", roundTimeSeconds%60))",
                               value: $roundTimeSeconds, in: 30...600, step: 30)
                        Stepper("Rest: \(restTimeSeconds)s", value: $restTimeSeconds, in: 15...180, step: 15)
                    }
                }
            }
            .navigationTitle("Add Drill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addDrill()
                    }
                    .font(.body.bold())
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addDrill() {
        let comboNumbers: String? = {
            if !customCombo.trimmingCharacters(in: .whitespaces).isEmpty {
                return customCombo.trimmingCharacters(in: .whitespaces)
            }
            return selectedCombo?.numbers
        }()

        let drill = LessonDrill(
            title: title.trimmingCharacters(in: .whitespaces),
            comboNumbers: comboNumbers,
            reps: useReps ? reps : nil,
            rounds: useReps ? nil : rounds,
            roundTimeSeconds: useReps ? nil : roundTimeSeconds,
            restTimeSeconds: useReps ? nil : restTimeSeconds,
            notes: notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes
        )
        drills.append(drill)
        dismiss()
    }
}

struct EditLessonSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var lesson: Lesson

    @State private var title: String
    @State private var notes: String
    @State private var difficulty: LessonDifficulty
    @State private var durationMinutes: Int
    @State private var warmupNotes: String
    @State private var cooldownNotes: String
    @State private var drills: [LessonDrill]
    @State private var exercises: [ExerciseSlot]
    @State private var showingAddExercise = false

    init(lesson: Lesson) {
        self.lesson = lesson
        _title = State(initialValue: lesson.title)
        _notes = State(initialValue: lesson.notes ?? "")
        _difficulty = State(initialValue: lesson.difficulty)
        _durationMinutes = State(initialValue: lesson.durationMinutes)
        _warmupNotes = State(initialValue: lesson.warmupNotes ?? "")
        _cooldownNotes = State(initialValue: lesson.cooldownNotes ?? "")
        _drills = State(initialValue: lesson.drills)
        _exercises = State(initialValue: lesson.exercises)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Lesson Info") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(LessonDifficulty.allCases) { level in
                            Label(level.rawValue, systemImage: level.icon).tag(level)
                        }
                    }
                    Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 10...120, step: 5)
                }

                Section("Warmup") {
                    TextField("Warmup notes", text: $warmupNotes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    ForEach(exercises) { exercise in
                        ExerciseRowEditable(exercise: exercise)
                    }
                    .onDelete { exercises.remove(atOffsets: $0) }
                    .onMove { exercises.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        showingAddExercise = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Exercises")
                }

                Section("Cooldown") {
                    TextField("Cooldown notes", text: $cooldownNotes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Edit Lesson")
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseSheet(exercises: $exercises)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
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
        lesson.title = title.trimmingCharacters(in: .whitespaces)
        lesson.notes = notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes
        lesson.difficulty = difficulty
        lesson.durationMinutes = durationMinutes
        lesson.warmupNotes = warmupNotes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : warmupNotes
        lesson.cooldownNotes = cooldownNotes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : cooldownNotes
        lesson.drills = drills
        lesson.exercises = exercises
        lesson.updatedAt = Date()
        dismiss()
    }
}

#Preview {
    CreateLessonSheet()
        .modelContainer(for: [Session.self, Technique.self, ProgressNote.self, Location.self, Combo.self, Lesson.self], inMemory: true)
}
