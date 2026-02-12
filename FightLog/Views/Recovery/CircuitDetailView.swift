import SwiftUI

struct CircuitDetailView: View {
    let circuit: RecoveryCircuit

    @State private var isRunning = false
    @State private var currentExerciseIndex = 0
    @State private var timeRemaining = 0
    @State private var timer: Timer?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: circuit.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(circuit.color)
                        .frame(width: 80, height: 80)
                        .background(circuit.color.opacity(0.15))
                        .clipShape(Circle())

                    Text(circuit.focusDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 16) {
                        Label("\(circuit.totalMinutes) min", systemImage: "timer")
                        Label("\(circuit.exercises.count) exercises", systemImage: "list.number")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                // Timer Controls
                if isRunning {
                    timerView
                }

                // Start Button
                Button {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                } label: {
                    HStack {
                        Image(systemName: isRunning ? "stop.fill" : "play.fill")
                        Text(isRunning ? "Stop Circuit" : "Start Circuit")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isRunning ? Color.red : circuit.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                // Exercise List
                VStack(spacing: 12) {
                    ForEach(Array(circuit.exercises.enumerated()), id: \.element.id) { index, exercise in
                        exerciseRow(exercise, index: index)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(circuit.name)
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            stopTimer()
        }
    }

    private var timerView: some View {
        VStack(spacing: 8) {
            Text(circuit.exercises[currentExerciseIndex].name)
                .font(.title3.bold())

            Text(formatTime(timeRemaining))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(circuit.color)

            Text("Exercise \(currentExerciseIndex + 1) of \(circuit.exercises.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                Button {
                    if currentExerciseIndex > 0 {
                        currentExerciseIndex -= 1
                        timeRemaining = exerciseDuration(circuit.exercises[currentExerciseIndex])
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                        .foregroundStyle(currentExerciseIndex > 0 ? circuit.color : .gray)
                }
                .disabled(currentExerciseIndex == 0)

                Button {
                    skipToNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundStyle(currentExerciseIndex < circuit.exercises.count - 1 ? circuit.color : .gray)
                }
                .disabled(currentExerciseIndex >= circuit.exercises.count - 1)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func exerciseRow(_ exercise: StretchExercise, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isRunning && index == currentExerciseIndex ? circuit.color : Color(.systemGray4))
                    .frame(width: 32, height: 32)

                Text("\(index + 1)")
                    .font(.caption.bold())
                    .foregroundStyle(isRunning && index == currentExerciseIndex ? .white : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(isRunning && index == currentExerciseIndex ? .primary : .primary)
                Text(exercise.targetMuscles)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(exercise.duration)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(isRunning && index == currentExerciseIndex ? circuit.color.opacity(0.1) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    // MARK: - Timer Logic

    private func startTimer() {
        currentExerciseIndex = 0
        timeRemaining = exerciseDuration(circuit.exercises[0])
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                skipToNext()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func skipToNext() {
        if currentExerciseIndex < circuit.exercises.count - 1 {
            currentExerciseIndex += 1
            timeRemaining = exerciseDuration(circuit.exercises[currentExerciseIndex])
        } else {
            stopTimer()
        }
    }

    private func exerciseDuration(_ exercise: StretchExercise) -> Int {
        // Parse duration string to get seconds — default 30s per side
        let text = exercise.duration.lowercased()
        if text.contains("45") { return 45 }
        if text.contains("each side") || text.contains("each direction") || text.contains("each hand") { return 60 }
        if text.contains("10 reps") { return 30 }
        return 30
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
