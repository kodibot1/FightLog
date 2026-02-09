import SwiftUI
import AVFoundation

struct RoundTimerView: View {
    @State private var roundLength: Int = 180  // 3 minutes
    @State private var restLength: Int = 60    // 1 minute
    @State private var totalRounds: Int = 3
    @State private var currentRound: Int = 1
    @State private var timeRemaining: Int = 180
    @State private var isRunning: Bool = false
    @State private var isResting: Bool = false
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Round indicator
                HStack(spacing: 8) {
                    ForEach(1...totalRounds, id: \.self) { round in
                        Circle()
                            .fill(round < currentRound ? Color.green :
                                  round == currentRound ? Color.orange : Color(.systemGray4))
                            .frame(width: 12, height: 12)
                    }
                }

                // Status
                Text(isResting ? "REST" : "ROUND \(currentRound)")
                    .font(.title2.bold())
                    .foregroundStyle(isResting ? .blue : .orange)

                // Timer display
                Text(formatTime(timeRemaining))
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundStyle(isResting ? .blue : .primary)

                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        .frame(width: 200, height: 200)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(isResting ? Color.blue : Color.orange, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                }

                // Controls
                HStack(spacing: 32) {
                    Button {
                        resetTimer()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }

                    Button {
                        toggleTimer()
                    } label: {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .background(isRunning ? Color.red : Color.green)
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }

                    Button {
                        skipToNext()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }

                Spacer()

                // Settings
                VStack(spacing: 16) {
                    HStack {
                        Text("Round Length")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("", selection: $roundLength) {
                            Text("2:00").tag(120)
                            Text("3:00").tag(180)
                            Text("5:00").tag(300)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }

                    HStack {
                        Text("Rest Length")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("", selection: $restLength) {
                            Text("0:30").tag(30)
                            Text("1:00").tag(60)
                            Text("1:30").tag(90)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }

                    HStack {
                        Text("Rounds")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Stepper("\(totalRounds)", value: $totalRounds, in: 1...12)
                            .frame(width: 120)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .disabled(isRunning)
                .opacity(isRunning ? 0.5 : 1)
            }
            .padding()
            .navigationTitle("Round Timer")
            .onChange(of: roundLength) { _, newValue in
                if !isRunning && !isResting {
                    timeRemaining = newValue
                }
            }
        }
    }

    private var progress: Double {
        let total = isResting ? Double(restLength) : Double(roundLength)
        return Double(timeRemaining) / total
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1

                // Warning beep at 10 seconds
                if timeRemaining == 10 {
                    playSound(warning: true)
                }
            } else {
                // Time's up
                playSound(warning: false)

                if isResting {
                    // Rest over, start next round
                    isResting = false
                    timeRemaining = roundLength
                } else {
                    // Round over
                    if currentRound < totalRounds {
                        // Start rest
                        isResting = true
                        timeRemaining = restLength
                        currentRound += 1
                    } else {
                        // Workout complete
                        stopTimer()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
            }
        }
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        stopTimer()
        currentRound = 1
        isResting = false
        timeRemaining = roundLength
    }

    private func skipToNext() {
        if isResting {
            isResting = false
            timeRemaining = roundLength
        } else if currentRound < totalRounds {
            isResting = true
            timeRemaining = restLength
            currentRound += 1
        } else {
            resetTimer()
        }
    }

    private func playSound(warning: Bool) {
        let systemSoundID: SystemSoundID = warning ? 1052 : 1304
        AudioServicesPlaySystemSound(systemSoundID)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}

#Preview {
    RoundTimerView()
}
