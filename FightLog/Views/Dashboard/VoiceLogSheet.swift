import SwiftUI
import SwiftData

struct VoiceLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var techniques: [Technique]
    @Query private var combos: [Combo]
    @Query private var profiles: [UserProfile]

    @State private var viewModel = VoiceLogViewModel()
    @State private var showingAPIKeySheet = false
    @State private var showingTechniquePicker = false
    @State private var showingComboPicker = false

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .quickContext:
                    quickContextPhase
                case .guidedRecall:
                    guidedRecallPhase
                case .assembling:
                    assemblingPhase
                case .review:
                    reviewPhase
                case .saving:
                    EmptyView()
                }
            }
            .navigationTitle("Voice Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.speechService.stopRecording()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAPIKeySheet = true
                    } label: {
                        Image(systemName: "key.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingAPIKeySheet) {
                APIKeySheet()
            }
            .sheet(isPresented: $showingTechniquePicker) {
                NavigationStack {
                    TechniquePickerView(selectedTechniques: $viewModel.selectedTechniques)
                }
            }
            .sheet(isPresented: $showingComboPicker) {
                NavigationStack {
                    ComboPickerView(selectedCombos: $viewModel.selectedCombos)
                }
            }
            .onAppear {
                viewModel.applyProfileDefaults(profiles.first)
            }
        }
    }

    // MARK: - Phase 1: Quick Context

    private var quickContextPhase: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)
                    Text("Quick Setup")
                        .font(.title2.bold())
                    Text("Tap a few things, then we'll help you remember the rest")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
                .padding(.horizontal)

                // Session Type
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("What type of session?", icon: "figure.boxing")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(SessionType.allCases) { type in
                            SessionTypeButton(type: type, isSelected: viewModel.selectedSessionType == type) {
                                viewModel.selectedSessionType = type
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Duration
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("How long?", icon: "clock")

                    HStack(spacing: 10) {
                        ForEach([30, 45, 60, 90, 120], id: \.self) { mins in
                            DurationButton(minutes: mins, isSelected: viewModel.selectedDuration == mins) {
                                viewModel.selectedDuration = mins
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Intensity
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Intensity?", icon: "flame")

                    HStack(spacing: 10) {
                        ForEach(Intensity.allCases) { intensity in
                            IntensityButton(intensity: intensity, isSelected: viewModel.selectedIntensity == intensity) {
                                viewModel.selectedIntensity = viewModel.selectedIntensity == intensity ? nil : intensity
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Did you spar?
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Did you spar?", icon: "person.2.fill")

                    HStack(spacing: 12) {
                        sparButton("Yes", isSelected: viewModel.didSpar) {
                            viewModel.didSpar = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        sparButton("No", isSelected: !viewModel.didSpar) {
                            viewModel.didSpar = false
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                }
                .padding(.horizontal)

                // API key warning
                if !AIService.shared.hasAPIKey {
                    Button {
                        showingAPIKeySheet = true
                    } label: {
                        HStack {
                            Image(systemName: "key.fill")
                            Text("Add API Key to Continue")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    }
                }

                // Start Recall button
                Button {
                    viewModel.startGuidedRecall()
                } label: {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Start Recall")
                            .font(.body.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AIService.shared.hasAPIKey ? Color.orange : Color(.systemGray4))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!AIService.shared.hasAPIKey)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.vertical)
        }
    }

    // MARK: - Phase 2: Guided Recall

    private var guidedRecallPhase: some View {
        VStack(spacing: 0) {
            // Progress bar
            HStack {
                Text("Question \(viewModel.conversation.count + 1)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                if viewModel.answeredCount >= 2 {
                    Button {
                        Task {
                            await viewModel.finishRecall(
                                techniques: techniques,
                                combos: combos,
                                profile: profiles.first
                            )
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("I'm Done")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))

            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Context summary
                        contextSummaryBubble

                        // Past conversation turns
                        ForEach(Array(viewModel.conversation.enumerated()), id: \.offset) { index, turn in
                            aiQuestionBubble(turn.question)
                            if !turn.answer.isEmpty {
                                userAnswerBubble(turn.answer)
                            } else {
                                skippedBubble
                            }
                        }

                        // Current question
                        if viewModel.isLoadingQuestion {
                            aiTypingBubble
                                .id("current")
                        } else {
                            aiQuestionBubble(viewModel.currentQuestion)
                                .id("current")
                        }

                        // Error
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.conversation.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo("current", anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.isLoadingQuestion) { _, _ in
                    withAnimation {
                        proxy.scrollTo("current", anchor: .bottom)
                    }
                }
            }

            Divider()

            // Input bar
            inputBar
        }
    }

    // MARK: - Phase 2: Chat Bubbles

    private var contextSummaryBubble: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.selectedSessionType.rawValue) \u{2022} \(viewModel.selectedDuration)min\(viewModel.selectedIntensity.map { " \u{2022} \($0.rawValue)" } ?? "")\(viewModel.didSpar ? " \u{2022} Sparring" : "")")
                    .font(.caption.bold())
            }
            .padding(10)
            .background(Color.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
        }
    }

    private func aiQuestionBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(.purple)
                .frame(width: 24, height: 24)
                .background(Color.purple.opacity(0.15))
                .clipShape(Circle())

            Text(text)
                .font(.body)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer(minLength: 40)
        }
    }

    private func userAnswerBubble(_ text: String) -> some View {
        HStack {
            Spacer(minLength: 40)
            Text(text)
                .font(.body)
                .foregroundStyle(.white)
                .padding(12)
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var skippedBubble: some View {
        HStack {
            Spacer(minLength: 40)
            Text("Skipped")
                .font(.caption)
                .foregroundStyle(.secondary)
                .italic()
                .padding(8)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var aiTypingBubble: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(.purple)
                .frame(width: 24, height: 24)
                .background(Color.purple.opacity(0.15))
                .clipShape(Circle())

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer(minLength: 40)
        }
    }

    // MARK: - Phase 2: Input Bar

    private var inputBar: some View {
        VStack(spacing: 8) {
            // Transcription preview
            if viewModel.speechService.isRecording {
                Text(viewModel.speechService.transcribedText.isEmpty ? "Listening..." : viewModel.speechService.transcribedText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .onChange(of: viewModel.speechService.transcribedText) { _, newValue in
                        if !newValue.isEmpty {
                            viewModel.currentAnswer = newValue
                        }
                    }
            }

            HStack(spacing: 10) {
                // Skip button
                Button {
                    Task {
                        await viewModel.skipQuestion(
                            techniques: techniques,
                            combos: combos,
                            profile: profiles.first
                        )
                    }
                } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .disabled(viewModel.isLoadingQuestion)

                // Text field
                TextField("Type or tap mic...", text: $viewModel.currentAnswer, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .lineLimit(1...3)

                // Mic button
                Button {
                    Task { await viewModel.toggleRecording() }
                } label: {
                    Image(systemName: viewModel.speechService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(viewModel.speechService.isRecording ? .red : .orange)
                }
                .disabled(viewModel.isLoadingQuestion)

                // Send button
                if !viewModel.currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        Task {
                            viewModel.speechService.stopRecording()
                            await viewModel.submitAnswer(
                                techniques: techniques,
                                combos: combos,
                                profile: profiles.first
                            )
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }

    // MARK: - Phase 3: Assembling

    private var assemblingPhase: some View {
        VStack(spacing: 20) {
            Spacer()

            ProgressView()
                .scaleEffect(1.5)

            Text("Putting it all together...")
                .font(.headline)

            Text("AI is assembling your session from the conversation")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    // MARK: - Phase 4: Review

    private var reviewPhase: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Session Type
                sessionTypeSuggestion

                // Duration & Intensity
                durationIntensitySuggestion

                // Workout Breakdown (drills) - primary content
                if !viewModel.suggestedDrills.isEmpty {
                    workoutBreakdownSection
                }

                // What went well / to improve
                insightsSection

                // Techniques (collapsed)
                DisclosureGroup {
                    techniqueSuggestionsContent
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.orange)
                        Text("Techniques (\(viewModel.selectedTechniques.count))")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)

                // Combos (collapsed)
                DisclosureGroup {
                    comboSuggestionsContent
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(.orange)
                        Text("Combos (\(viewModel.selectedCombos.count))")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)

                // Notes
                notesSection

                // Save button
                Button {
                    viewModel.saveSession(modelContext: modelContext)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Session")
                            .font(.body.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                // Start over
                Button {
                    viewModel.reset()
                    viewModel.applyProfileDefaults(profiles.first)
                } label: {
                    Text("Start Over")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Workout Breakdown

    private var workoutBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Workout Breakdown", icon: "list.bullet.rectangle")

            ForEach(viewModel.suggestedDrills) { drill in
                DrillBlockView(drill: drill)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Review Sections

    private var sessionTypeSuggestion: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Session Type", icon: "figure.boxing")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(SessionType.allCases) { type in
                    SessionTypeButton(type: type, isSelected: viewModel.selectedSessionType == type) {
                        viewModel.selectedSessionType = type
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .overlay {
                        if viewModel.suggestedSessionType == type {
                            aiSuggestedBadge
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var durationIntensitySuggestion: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Duration
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Duration", icon: "clock")

                HStack(spacing: 12) {
                    ForEach([15, 30, 45, 60, 90], id: \.self) { mins in
                        DurationButton(minutes: mins, isSelected: viewModel.selectedDuration == mins) {
                            viewModel.selectedDuration = mins
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                }

                HStack {
                    Text("Custom:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Stepper("\(viewModel.selectedDuration) min", value: $viewModel.selectedDuration, in: 5...180, step: 5)
                }
            }

            // Intensity
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Intensity", icon: "flame")

                HStack(spacing: 12) {
                    ForEach(Intensity.allCases) { intensity in
                        IntensityButton(intensity: intensity, isSelected: viewModel.selectedIntensity == intensity) {
                            viewModel.selectedIntensity = viewModel.selectedIntensity == intensity ? nil : intensity
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var techniqueSuggestionsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button {
                    showingTechniquePicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("More")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                }
            }

            if !viewModel.selectedTechniques.isEmpty || !viewModel.suggestedTechniqueNames.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(viewModel.selectedTechniques).sorted(by: { $0.name < $1.name })) { technique in
                        TechniqueChip(technique: technique, isSelected: true) {
                            viewModel.selectedTechniques.remove(technique)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }

                    let matchedNames = Set(viewModel.selectedTechniques.map { $0.name.lowercased() })
                    ForEach(viewModel.suggestedTechniqueNames.filter { !matchedNames.contains($0.lowercased()) }, id: \.self) { name in
                        unmatchedChip(name, color: .orange)
                    }
                }
            } else {
                Text("No techniques detected. Tap More to add.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var comboSuggestionsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button {
                    showingComboPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("More")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                }
            }

            if !viewModel.selectedCombos.isEmpty || !viewModel.suggestedComboNames.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(viewModel.selectedCombos).sorted(by: { $0.numbers < $1.numbers })) { combo in
                        ComboChip(combo: combo, isSelected: true) {
                            viewModel.selectedCombos.remove(combo)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }

                    let matchedNumbers = Set(viewModel.selectedCombos.map { $0.numbers.lowercased() })
                    let matchedNames = Set(viewModel.selectedCombos.compactMap { $0.name?.lowercased() })
                    ForEach(viewModel.suggestedComboNames.filter {
                        !matchedNumbers.contains($0.lowercased()) && !matchedNames.contains($0.lowercased())
                    }, id: \.self) { name in
                        unmatchedChip(name, color: .red)
                    }
                }
            } else {
                Text("No combos detected. Tap More to add.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.wentWell != nil || viewModel.toImprove != nil {
                sectionHeader("AI Insights", icon: "sparkles")

                if let wentWell = viewModel.wentWell, !wentWell.isEmpty {
                    insightCard(title: "What went well", text: wentWell, color: .green)
                }

                if let toImprove = viewModel.toImprove, !toImprove.isEmpty {
                    insightCard(title: "To improve", text: toImprove, color: .orange)
                }
            }
        }
        .padding(.horizontal)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Notes", icon: "note.text")

            TextField("Add any additional notes...", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .lineLimit(3...6)
        }
        .padding(.horizontal)
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
            Text(title)
                .font(.headline)
        }
    }

    private func sparButton(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var aiSuggestedBadge: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Color.purple)
                    .clipShape(Circle())
                    .offset(x: 4, y: -4)
            }
            Spacer()
        }
    }

    private func insightCard(title: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(color)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func unmatchedChip(_ name: String, color: Color) -> some View {
        Text(name)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(color.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Drill Block View

struct DrillBlockView: View {
    let drill: DrillEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with icon and name
            HStack(spacing: 8) {
                Image(systemName: drill.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 28, height: 28)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(drill.name)
                    .font(.subheadline.bold())
            }

            // Description
            Text(drill.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Combo tags
            if !drill.combos.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(drill.combos, id: \.self) { combo in
                        Text(combo)
                            .font(.caption.monospaced())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.15))
                            .foregroundStyle(.red)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
