import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var currentPage = 0
    @State private var username = ""
    @State private var selectedDisciplines: Set<MartialArtDiscipline> = []
    @State private var selectedExperience: ExperienceLevel = .beginner
    @State private var selectedGoal: TrainingGoal = .fitness
    @State private var weeklyTarget = 3
    @State private var selectedSessionType: SessionType = .classSession
    @State private var typicalDuration: Int = 60
    @State private var selectedIntensity: Intensity = .moderate
    @State private var animateIn = false

    private let totalPages = 4

    var body: some View {
        ZStack {
            // Premium gradient background
            GeometryReader { geo in
                ZStack {
                    Color(uiColor: .systemBackground)
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.10),
                            Color.orange.opacity(0.04),
                            Color.clear
                        ],
                        center: .init(x: 0.5, y: 0.0),
                        startRadius: 20,
                        endRadius: geo.size.height * 0.55
                    )
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                if currentPage > 0 && currentPage < totalPages - 1 {
                    stepDots
                        .padding(.top, 16)
                }

                // Pages
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    aboutYouPage.tag(1)
                    trainingPage.tag(2)
                    readyPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: currentPage)
            }
        }
    }

    // MARK: - Step Dots (NutriTrack style)

    private var stepDots: some View {
        HStack(spacing: 6) {
            ForEach(1..<totalPages - 1, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.orange : Color.gray.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }

    // MARK: - Page 0: Welcome

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "figure.boxing")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
                .scaleEffect(animateIn ? 1 : 0.5)
                .opacity(animateIn ? 1 : 0)

            VStack(spacing: 8) {
                Text("FightLog")
                    .font(.largeTitle.bold())
                    .opacity(animateIn ? 1 : 0)

                Text("Your personal training journal")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .opacity(animateIn ? 1 : 0)
            }

            Spacer()

            onboardingButton("Get Started") {
                hapticLight()
                withAnimation { currentPage = 1 }
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateIn = true
            }
        }
    }

    // MARK: - Page 1: About You (Name + Disciplines)

    private var aboutYouPage: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Text("About You")
                        .font(.title.bold())
                    Text("Pick your discipline(s)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your name")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)

                    TextField("Fighter name", text: $username)
                        .font(.title3)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)

                // Discipline cards (multi-select)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(MartialArtDiscipline.allCases) { discipline in
                        let isSelected = selectedDisciplines.contains(discipline)
                        Button {
                            hapticLight()
                            if isSelected {
                                selectedDisciplines.remove(discipline)
                            } else {
                                selectedDisciplines.insert(discipline)
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text(discipline.emoji)
                                    .font(.system(size: 28))
                                Text(discipline.rawValue)
                                    .font(.subheadline.bold())
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(isSelected ? Color.orange.opacity(0.15) : Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(isSelected ? .orange : .primary)
                        }
                    }
                }
                .padding(.horizontal, 24)

                onboardingButton("Next", disabled: username.trimmingCharacters(in: .whitespaces).isEmpty || selectedDisciplines.isEmpty) {
                    hapticLight()
                    withAnimation { currentPage = 2 }
                }
                .padding(.bottom, 40)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Page 2: Training (Experience + Goal + Frequency)

    private var trainingPage: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Text("Your Training")
                        .font(.title.bold())
                    Text("This helps personalize your experience")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                // Experience Level
                VStack(alignment: .leading, spacing: 10) {
                    Text("Experience Level")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ExperienceLevel.allCases) { level in
                                let isSelected = selectedExperience == level
                                Button {
                                    hapticLight()
                                    selectedExperience = level
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(level.emoji)
                                            .font(.title2)
                                        Text(level.rawValue)
                                            .font(.caption.bold())
                                        Text(level.subtitle)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(width: 100, height: 80)
                                    .background(isSelected ? Color.orange.opacity(0.15) : Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(isSelected ? .orange : .primary)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }

                // Goal
                VStack(alignment: .leading, spacing: 10) {
                    Text("Main Goal")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(TrainingGoal.allCases) { goal in
                            let isSelected = selectedGoal == goal
                            Button {
                                hapticLight()
                                selectedGoal = goal
                            } label: {
                                VStack(spacing: 4) {
                                    Text(goal.emoji)
                                        .font(.title2)
                                    Text(goal.rawValue)
                                        .font(.caption.bold())
                                        .multilineTextAlignment(.center)
                                    Text(goal.subtitle)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 85)
                                .background(isSelected ? Color.orange.opacity(0.15) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(isSelected ? .orange : .primary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Weekly Frequency
                VStack(alignment: .leading, spacing: 10) {
                    Text("Training Frequency")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    HStack(spacing: 10) {
                        ForEach([2, 3, 4, 5, 6], id: \.self) { count in
                            let isSelected = weeklyTarget == count
                            Button {
                                hapticLight()
                                weeklyTarget = count
                            } label: {
                                Text("\(count)x")
                                    .font(.body.bold())
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(isSelected ? Color.orange.opacity(0.15) : Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(isSelected ? .orange : .primary)
                            }
                        }
                        Text("/ wk")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                }

                // Smart Hints - Typical Session
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Typical Session")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Smart defaults")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 24)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(SessionType.allCases) { type in
                                let isSelected = selectedSessionType == type
                                Button {
                                    hapticLight()
                                    selectedSessionType = type
                                    typicalDuration = type.defaultDuration
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: type.icon)
                                            .font(.title3)
                                        Text(type.rawValue)
                                            .font(.caption2.bold())
                                    }
                                    .frame(width: 80, height: 60)
                                    .background(isSelected ? Color.orange.opacity(0.15) : Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(isSelected ? .orange : .primary)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }

                // Typical Duration
                VStack(alignment: .leading, spacing: 10) {
                    Text("How long are your sessions?")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    HStack(spacing: 10) {
                        ForEach([30, 45, 60, 90], id: \.self) { mins in
                            let isSelected = typicalDuration == mins
                            Button {
                                hapticLight()
                                typicalDuration = mins
                            } label: {
                                Text("\(mins)m")
                                    .font(.body.bold())
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(isSelected ? Color.orange.opacity(0.15) : Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(isSelected ? .orange : .primary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Typical Intensity
                VStack(alignment: .leading, spacing: 10) {
                    Text("Usual intensity?")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    HStack(spacing: 10) {
                        ForEach(Intensity.allCases) { intensity in
                            let isSelected = selectedIntensity == intensity
                            Button {
                                hapticLight()
                                selectedIntensity = intensity
                            } label: {
                                Text(intensity.rawValue)
                                    .font(.body.bold())
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(isSelected ? intensityColor(intensity).opacity(0.15) : Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isSelected ? intensityColor(intensity) : Color.clear, lineWidth: 2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(isSelected ? intensityColor(intensity) : .primary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                onboardingButton("Next") {
                    hapticLight()
                    withAnimation { currentPage = 3 }
                }
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Page 3: Ready

    private var readyPage: some View {
        VStack(spacing: 24) {
            Spacer()

            // Summary rings
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)

                Text("You're All Set")
                    .font(.largeTitle.bold())

                Text("Here's your profile")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Summary cards
            VStack(spacing: 10) {
                summaryRow(emoji: "👤", label: "Name", value: username.isEmpty ? "Fighter" : username)
                summaryRow(
                    emoji: "🥋",
                    label: "Disciplines",
                    value: selectedDisciplines.map { $0.rawValue }.joined(separator: ", ")
                )
                summaryRow(emoji: selectedExperience.emoji, label: "Level", value: selectedExperience.rawValue)
                summaryRow(emoji: selectedGoal.emoji, label: "Goal", value: selectedGoal.rawValue)
                summaryRow(emoji: "📅", label: "Training", value: "\(weeklyTarget)x per week")
                summaryRow(emoji: "⏱️", label: "Session", value: "\(typicalDuration)m \(selectedSessionType.rawValue)")
            }
            .padding(.horizontal, 24)

            Spacer()

            onboardingButton("Let's Go!") {
                saveProfile()
            }
            .padding(.bottom, 40)
        }
    }

    private func summaryRow(emoji: String, label: String, value: String) -> some View {
        HStack {
            Text(emoji)
                .font(.title3)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Shared Components

    private func onboardingButton(_ title: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(disabled ? Color.gray : Color.orange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(disabled)
        .padding(.horizontal, 32)
    }

    // MARK: - Haptics

    private func hapticLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func hapticSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - Helpers

    private func intensityColor(_ intensity: Intensity) -> Color {
        switch intensity {
        case .light: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }

    // MARK: - Save

    private func saveProfile() {
        let profile = UserProfile(
            username: username.trimmingCharacters(in: .whitespaces),
            primaryGoal: selectedGoal,
            weeklyTarget: weeklyTarget,
            disciplines: Array(selectedDisciplines),
            experienceLevel: selectedExperience,
            typicalSessionLength: typicalDuration,
            preferredSessionType: selectedSessionType,
            preferredIntensity: selectedIntensity
        )
        modelContext.insert(profile)
        hapticSuccess()
    }
}
