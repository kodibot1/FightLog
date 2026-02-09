import Foundation
import SwiftData

enum SessionType: String, Codable, CaseIterable, Identifiable {
    case sparring = "Sparring"
    case drilling = "Drilling"
    case classSession = "Class"
    case bagWork = "Bag Work"
    case padWork = "Pad Work"
    case shadowBoxing = "Shadow Boxing"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sparring: return "figure.boxing"
        case .drilling: return "arrow.triangle.2.circlepath"
        case .classSession: return "person.3.fill"
        case .bagWork: return "figure.kickboxing"
        case .padWork: return "hands.clap.fill"
        case .shadowBoxing: return "figure.martial.arts"
        }
    }

    var defaultDuration: Int {
        switch self {
        case .sparring: return 15
        case .drilling: return 30
        case .classSession: return 60
        case .bagWork: return 30
        case .padWork: return 20
        case .shadowBoxing: return 15
        }
    }
}

enum Intensity: String, Codable, CaseIterable, Identifiable {
    case light = "Light"
    case moderate = "Moderate"
    case hard = "Hard"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .light: return "green"
        case .moderate: return "orange"
        case .hard: return "red"
        }
    }
}

@Model
final class Session {
    var id: UUID
    var sessionType: SessionType
    var duration: Int
    var intensity: Intensity?
    var notes: String?
    var timestamp: Date

    // Location (simple name, not GPS)
    var location: Location?

    @Relationship(deleteRule: .nullify, inverse: \Technique.sessions)
    var techniques: [Technique]

    @Relationship(deleteRule: .nullify, inverse: \Combo.sessions)
    var combos: [Combo]

    @Relationship(deleteRule: .nullify, inverse: \ProgressNote.session)
    var progressNotes: [ProgressNote]

    init(
        sessionType: SessionType,
        duration: Int? = nil,
        intensity: Intensity? = nil,
        notes: String? = nil,
        location: Location? = nil,
        techniques: [Technique] = [],
        combos: [Combo] = [],
        progressNotes: [ProgressNote] = [],
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.sessionType = sessionType
        self.duration = duration ?? sessionType.defaultDuration
        self.intensity = intensity
        self.notes = notes
        self.location = location
        self.techniques = techniques
        self.combos = combos
        self.progressNotes = progressNotes
        self.timestamp = timestamp
    }
}
