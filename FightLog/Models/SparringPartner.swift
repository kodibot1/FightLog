import Foundation
import SwiftData

@Model
final class SparringPartner {
    var id: UUID
    var name: String
    var nickname: String?
    var weightClass: String?
    var style: String?  // e.g., "Pressure fighter", "Counter puncher", "Southpaw"
    var notes: String?  // General notes about their tendencies
    var sessionCount: Int
    var lastSparred: Date?

    var sparringSessions: [SparringSession]?

    init(name: String, nickname: String? = nil, weightClass: String? = nil, style: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.nickname = nickname
        self.weightClass = weightClass
        self.style = style
        self.notes = notes
        self.sessionCount = 0
        self.lastSparred = nil
    }

    func recordSession() {
        sessionCount += 1
        lastSparred = Date()
    }
}

@Model
final class SparringSession {
    var id: UUID
    var date: Date
    var rounds: Int
    var roundLengthSeconds: Int
    var intensity: Intensity?
    var whatWorked: String?
    var whatDidntWork: String?
    var notes: String?

    @Relationship(deleteRule: .nullify)
    var partner: SparringPartner?

    @Relationship(deleteRule: .nullify)
    var linkedSession: Session?

    init(
        partner: SparringPartner?,
        rounds: Int = 3,
        roundLengthSeconds: Int = 180,
        intensity: Intensity? = nil,
        whatWorked: String? = nil,
        whatDidntWork: String? = nil,
        notes: String? = nil,
        linkedSession: Session? = nil
    ) {
        self.id = UUID()
        self.date = Date()
        self.partner = partner
        self.rounds = rounds
        self.roundLengthSeconds = roundLengthSeconds
        self.intensity = intensity
        self.whatWorked = whatWorked
        self.whatDidntWork = whatDidntWork
        self.notes = notes
        self.linkedSession = linkedSession
    }
}
