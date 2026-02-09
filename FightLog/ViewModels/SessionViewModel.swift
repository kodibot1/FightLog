import Foundation
import SwiftData
import SwiftUI

@Observable
class SessionViewModel {
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createSession(
        sessionType: SessionType,
        duration: Int,
        intensity: Intensity?,
        notes: String?,
        location: Location? = nil,
        techniques: [Technique],
        combos: [Combo] = []
    ) -> Session {
        let session = Session(
            sessionType: sessionType,
            duration: duration,
            intensity: intensity,
            notes: notes?.isEmpty == true ? nil : notes,
            location: location,
            techniques: techniques,
            combos: combos
        )

        modelContext.insert(session)

        // Update technique use counts
        for technique in techniques {
            technique.recordUse()
        }

        return session
    }

    func deleteSession(_ session: Session) {
        modelContext.delete(session)
    }

    func updateSession(
        _ session: Session,
        sessionType: SessionType? = nil,
        duration: Int? = nil,
        intensity: Intensity? = nil,
        notes: String? = nil,
        location: Location? = nil,
        techniques: [Technique]? = nil,
        combos: [Combo]? = nil
    ) {
        if let sessionType = sessionType {
            session.sessionType = sessionType
        }
        if let duration = duration {
            session.duration = duration
        }
        session.intensity = intensity
        session.notes = notes?.isEmpty == true ? nil : notes
        session.location = location

        if let techniques = techniques {
            // Update use counts for newly added techniques
            let newTechniques = techniques.filter { !session.techniques.contains($0) }
            for technique in newTechniques {
                technique.recordUse()
            }
            session.techniques = techniques
        }

        if let combos = combos {
            // Update use counts for newly added combos
            let newCombos = combos.filter { !session.combos.contains($0) }
            for combo in newCombos {
                combo.recordUse()
            }
            session.combos = combos
        }
    }

    func sessionsThisWeek(from sessions: [Session]) -> [Session] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return sessions.filter { $0.timestamp >= startOfWeek }
    }

    func totalTrainingTimeThisWeek(from sessions: [Session]) -> Int {
        sessionsThisWeek(from: sessions).reduce(0) { $0 + $1.duration }
    }

    func sessionsByWeek(from sessions: [Session]) -> [(key: Date, value: [Session])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session -> Date in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: session.timestamp))!
        }
        return grouped.sorted { $0.key > $1.key }
    }
}
