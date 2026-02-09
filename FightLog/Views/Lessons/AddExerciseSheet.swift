import SwiftUI

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var exercises: [ExerciseSlot]

    @State private var name = ""
    @State private var category: ExerciseCategory = .warmup
    @State private var equipment = ""
    @State private var isTimed = true
    @State private var durationMinutes = 5
    @State private var sets = 3
    @State private var reps = 10
    @State private var restSeconds = 60
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Info") {
                    TextField("Name (e.g., Skipping, Push-ups)", text: $name)

                    Picker("Category", selection: $category) {
                        ForEach(ExerciseCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }

                    TextField("Equipment (optional)", text: $equipment)
                }

                Section("Structure") {
                    Picker("Type", selection: $isTimed) {
                        Text("Timed").tag(true)
                        Text("Sets / Reps").tag(false)
                    }
                    .pickerStyle(.segmented)

                    if isTimed {
                        Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 1...60)
                    } else {
                        Stepper("Sets: \(sets)", value: $sets, in: 1...20)
                        Stepper("Reps: \(reps)", value: $reps, in: 1...200, step: 5)
                    }

                    Stepper("Rest: \(restSeconds)s", value: $restSeconds, in: 0...300, step: 15)
                }

                Section("Notes") {
                    TextField("Tips or instructions", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addExercise() }
                        .font(.body.bold())
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addExercise() {
        let exercise = ExerciseSlot(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category,
            equipment: equipment.trimmingCharacters(in: .whitespaces).isEmpty ? nil : equipment.trimmingCharacters(in: .whitespaces),
            sets: isTimed ? nil : sets,
            reps: isTimed ? nil : reps,
            durationSeconds: isTimed ? durationMinutes * 60 : nil,
            restSeconds: restSeconds > 0 ? restSeconds : nil,
            notes: notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces)
        )
        exercises.append(exercise)
        dismiss()
    }
}
