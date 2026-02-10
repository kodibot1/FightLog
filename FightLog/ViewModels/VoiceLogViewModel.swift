import Foundation
import SwiftData
import UIKit

enum VoiceLogPhase {
    case quickContext
    case guidedRecall
    case assembling
    case review
    case saving
}

@MainActor
@Observable
class VoiceLogViewModel {
    var phase: VoiceLogPhase = .quickContext
    var errorMessage: String?

    // Phase 1: Quick Context
    var selectedSessionType: SessionType = .classSession
    var selectedDuration: Int = 60
    var selectedIntensity: Intensity? = .moderate
    var didSpar: Bool = false

    // Phase 2: Guided Recall
    var conversation: [ConversationTurn] = []
    var currentQuestion: String = ""
    var currentAnswer: String = ""
    var isLoadingQuestion: Bool = false
    var answeredCount: Int { conversation.filter { !$0.answer.isEmpty }.count }

    // Phase 3: Review (AI analysis results)
    var suggestedSessionType: SessionType?
    var suggestedDuration: Int?
    var suggestedIntensity: Intensity?
    var suggestedTechniqueNames: [String] = []
    var suggestedComboNames: [String] = []
    var suggestedDrills: [DrillEntry] = []
    var wentWell: String?
    var toImprove: String?
    var followUpQuestions: [String] = []

    // User selections (post-review)
    var selectedTechniques: Set<Technique> = []
    var selectedCombos: Set<Combo> = []
    var notes: String = ""

    // Speech
    let speechService = SpeechRecognitionService()

    // MARK: - Smart Defaults

    func applyProfileDefaults(_ profile: UserProfile?) {
        guard let profile else { return }
        selectedSessionType = profile.preferredSessionType
        selectedDuration = profile.typicalSessionLength
        selectedIntensity = profile.preferredIntensity
    }

    // MARK: - Phase Transitions

    func startGuidedRecall() {
        phase = .guidedRecall
        currentQuestion = "Walk me through your session - what did you start with?"
        currentAnswer = ""
        conversation = []
    }

    func toggleRecording() async {
        if speechService.isRecording {
            speechService.stopRecording()
            currentAnswer = speechService.transcribedText
        } else {
            speechService.transcribedText = ""
            await speechService.startRecording()
        }
    }

    func submitAnswer(
        techniques: [Technique],
        combos: [Combo],
        profile: UserProfile?
    ) async {
        let answer = currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else { return }

        speechService.stopRecording()
        conversation.append(ConversationTurn(question: currentQuestion, answer: answer))
        currentAnswer = ""

        await fetchNextQuestion(techniques: techniques, combos: combos, profile: profile)
    }

    func skipQuestion(
        techniques: [Technique],
        combos: [Combo],
        profile: UserProfile?
    ) async {
        speechService.stopRecording()
        conversation.append(ConversationTurn(question: currentQuestion, answer: ""))
        currentAnswer = ""

        await fetchNextQuestion(techniques: techniques, combos: combos, profile: profile)
    }

    func finishRecall(
        techniques: [Technique],
        combos: [Combo],
        profile: UserProfile?
    ) async {
        // If there's a pending answer, add it first
        let answer = currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        if !answer.isEmpty {
            speechService.stopRecording()
            conversation.append(ConversationTurn(question: currentQuestion, answer: answer))
            currentAnswer = ""
        }

        await assembleSession(techniques: techniques, combos: combos, profile: profile)
    }

    // MARK: - AI Calls

    private func fetchNextQuestion(
        techniques: [Technique],
        combos: [Combo],
        profile: UserProfile?
    ) async {
        isLoadingQuestion = true
        errorMessage = nil

        let quickContext = QuickContext(
            sessionType: selectedSessionType,
            duration: selectedDuration,
            intensity: selectedIntensity,
            didSpar: didSpar
        )

        do {
            let result = try await AIService.shared.generateNextQuestion(
                quickContext: quickContext,
                conversationSoFar: conversation,
                techniqueNames: techniques.map { $0.name },
                comboNames: combos.map { $0.displayName },
                userContext: profile?.aiContext
            )

            isLoadingQuestion = false

            if result.isComplete {
                await assembleSession(techniques: techniques, combos: combos, profile: profile)
            } else {
                currentQuestion = result.question
            }
        } catch {
            isLoadingQuestion = false
            errorMessage = error.localizedDescription
            // Fallback: let user finish manually
            currentQuestion = "Anything else you'd like to add about your session?"
        }
    }

    private func assembleSession(
        techniques: [Technique],
        combos: [Combo],
        profile: UserProfile?
    ) async {
        phase = .assembling
        errorMessage = nil

        let quickContext = QuickContext(
            sessionType: selectedSessionType,
            duration: selectedDuration,
            intensity: selectedIntensity,
            didSpar: didSpar
        )

        do {
            let analysis = try await AIService.shared.assembleSessionFromConversation(
                quickContext: quickContext,
                conversation: conversation,
                techniqueNames: techniques.map { $0.name },
                comboNames: combos.map { $0.displayName },
                userContext: profile?.aiContext
            )

            applyAnalysis(analysis, techniques: techniques, combos: combos)
            phase = .review
        } catch {
            errorMessage = error.localizedDescription
            phase = .guidedRecall
        }
    }

    // MARK: - Apply Analysis

    private func applyAnalysis(
        _ analysis: AISessionAnalysis,
        techniques: [Technique],
        combos: [Combo]
    ) {
        // Session type - use quick context selection, but note AI suggestion
        if let typeStr = analysis.sessionType {
            suggestedSessionType = SessionType.allCases.first { $0.rawValue == typeStr }
        }

        // Duration - use quick context selection
        if let dur = analysis.duration {
            suggestedDuration = dur
        }

        // Intensity - use quick context selection
        if let intStr = analysis.intensity {
            suggestedIntensity = Intensity.allCases.first { $0.rawValue == intStr }
        }

        // Match techniques by name (case-insensitive)
        suggestedTechniqueNames = analysis.techniques
        for name in analysis.techniques {
            if let match = techniques.first(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) {
                selectedTechniques.insert(match)
            }
        }

        // Match combos by numbers or display name
        suggestedComboNames = analysis.combos
        for name in analysis.combos {
            if let match = combos.first(where: {
                $0.numbers.localizedCaseInsensitiveCompare(name) == .orderedSame ||
                $0.displayName.localizedCaseInsensitiveCompare(name) == .orderedSame
            }) {
                selectedCombos.insert(match)
            }
        }

        // Drills
        if let aiDrills = analysis.drills {
            suggestedDrills = aiDrills.map { drill in
                DrillEntry(
                    name: drill.name,
                    description: drill.description,
                    combos: drill.combos ?? []
                )
            }
        }

        // Text fields
        wentWell = analysis.wentWell
        toImprove = analysis.toImprove
        followUpQuestions = analysis.followUpQuestions

        // Build notes from AI insights
        var notesParts: [String] = []
        if let well = wentWell, !well.isEmpty {
            notesParts.append("Went well: \(well)")
        }
        if let improve = toImprove, !improve.isEmpty {
            notesParts.append("To improve: \(improve)")
        }
        notes = notesParts.joined(separator: "\n")
    }

    // MARK: - Save

    func saveSession(modelContext: ModelContext) {
        phase = .saving

        for combo in selectedCombos { combo.recordUse() }

        let session = Session(
            sessionType: selectedSessionType,
            duration: selectedDuration,
            intensity: selectedIntensity,
            notes: notes.isEmpty ? nil : notes,
            techniques: Array(selectedTechniques),
            combos: Array(selectedCombos),
            drills: suggestedDrills
        )
        modelContext.insert(session)

        for technique in selectedTechniques { technique.recordUse() }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - Reset

    func reset() {
        phase = .quickContext
        errorMessage = nil

        // Quick context
        selectedSessionType = .classSession
        selectedDuration = 60
        selectedIntensity = .moderate
        didSpar = false

        // Guided recall
        conversation = []
        currentQuestion = ""
        currentAnswer = ""
        isLoadingQuestion = false

        // Review
        suggestedSessionType = nil
        suggestedDuration = nil
        suggestedIntensity = nil
        suggestedTechniqueNames = []
        suggestedComboNames = []
        suggestedDrills = []
        wentWell = nil
        toImprove = nil
        followUpQuestions = []
        selectedTechniques = []
        selectedCombos = []
        notes = ""
    }
}
