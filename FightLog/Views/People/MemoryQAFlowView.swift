import SwiftUI

struct MemoryQAFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var person: Person

    @State private var availableQuestions: [MemoryQuestion] = []
    @State private var currentIndex = 0
    @State private var answerText = ""
    @State private var detailsAdded = 0
    @State private var showCelebration = false
    @State private var counterScale: CGFloat = 1.0

    // Card animation state
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1
    @State private var cardScale: CGFloat = 1
    @State private var enterFromRight = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if showCelebration {
                    celebrationView
                } else if currentIndex < availableQuestions.count {
                    VStack(spacing: 24) {
                        // Progress counter
                        HStack {
                            Spacer()
                            Text("\(detailsAdded) detail\(detailsAdded == 1 ? "" : "s") added")
                                .font(.subheadline.bold())
                                .foregroundStyle(.cyan)
                                .scaleEffect(counterScale)
                        }
                        .padding(.horizontal)

                        Spacer()

                        // Question card
                        questionCard(for: availableQuestions[currentIndex])
                            .offset(x: cardOffset)
                            .opacity(cardOpacity)
                            .scaleEffect(cardScale)

                        Spacer()

                        // Action buttons
                        HStack(spacing: 16) {
                            Button {
                                skipQuestion()
                            } label: {
                                Text("Skip")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            Button {
                                swapQuestion()
                            } label: {
                                Text("Different")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            Button {
                                saveAnswer()
                            } label: {
                                Text("Save")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(answerText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.cyan.opacity(0.4) : Color.cyan)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(answerText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        finishFlow()
                    }
                }
            }
        }
        .onAppear {
            setupQuestions()
        }
    }

    private func questionCard(for question: MemoryQuestion) -> some View {
        VStack(spacing: 20) {
            Image(systemName: question.icon)
                .font(.system(size: 48))
                .foregroundStyle(.cyan)

            Text(question.question)
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            TextField(question.placeholder, text: $answerText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .lineLimit(3...5)
        }
        .padding(24)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal)
    }

    private func setupQuestions() {
        availableQuestions = MemoryQuestions.allQuestions.filter { question in
            person.memoryAids[question.id] == nil || person.memoryAids[question.id]?.isEmpty == true
        }
    }

    private func skipQuestion() {
        animateCardOut(toRight: false) {
            advanceToNext()
            enterFromRight = true
            animateCardIn()
        }
    }

    private func saveAnswer() {
        let trimmed = answerText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let question = availableQuestions[currentIndex]
        person.memoryAids[question.id] = trimmed
        person.compileDescription()

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        detailsAdded += 1
        pulseCounter()

        animateCardOut(toRight: true) {
            advanceToNext()
            enterFromRight = false
            animateCardIn()
        }
    }

    private func swapQuestion() {
        guard availableQuestions.count > 1 else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            cardScale = 0.8
            cardOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Move current question to end
            let current = availableQuestions.remove(at: currentIndex)
            availableQuestions.append(current)
            if currentIndex >= availableQuestions.count {
                currentIndex = 0
            }
            answerText = ""
            cardScale = 0.8

            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
        }
    }

    private func advanceToNext() {
        answerText = ""
        // Remove answered questions
        availableQuestions = availableQuestions.filter { q in
            person.memoryAids[q.id] == nil || person.memoryAids[q.id]?.isEmpty == true
        }
        if currentIndex >= availableQuestions.count {
            currentIndex = 0
        }
        if availableQuestions.isEmpty {
            finishFlow()
        }
    }

    private func animateCardOut(toRight: Bool, completion: @escaping () -> Void) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            cardOffset = toRight ? 300 : -300
            cardOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion()
        }
    }

    private func animateCardIn() {
        cardOffset = enterFromRight ? 300 : -300
        cardOpacity = 0
        cardScale = 1.0

        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            cardOffset = 0
            cardOpacity = 1
        }
    }

    private func pulseCounter() {
        withAnimation(.spring(response: 0.2)) {
            counterScale = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.2)) {
                counterScale = 1.0
            }
        }
    }

    private func finishFlow() {
        person.compileDescription()
        showCelebration = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }

    @State private var celebrationScale: CGFloat = 0.5

    private var celebrationView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.cyan)
                .scaleEffect(celebrationScale)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        celebrationScale = 1.0
                    }
                }

            Text("\(detailsAdded) detail\(detailsAdded == 1 ? "" : "s") saved!")
                .font(.title2.bold())
        }
    }
}
