import Foundation
import SwiftData

enum TechniqueCategory: String, Codable, CaseIterable, Identifiable {
    case punch = "Punches"
    case kick = "Kicks"
    case elbow = "Elbows"
    case knee = "Knees"
    case clinch = "Clinch"
    case footwork = "Footwork"
    case defense = "Defense"
    case combination = "Combinations"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .punch: return "hand.raised.fill"
        case .kick: return "figure.kickboxing"
        case .elbow: return "arrow.up.right"
        case .knee: return "arrow.up"
        case .clinch: return "figure.wrestling"
        case .footwork: return "shoeprints.fill"
        case .defense: return "shield.fill"
        case .combination: return "list.bullet"
        }
    }
}

@Model
final class Technique {
    var id: UUID
    var name: String
    var category: TechniqueCategory
    var useCount: Int
    var lastUsed: Date?

    // New: Proficiency rating (1-5 stars)
    var proficiencyRating: Int  // 0 = not rated, 1-5 = rating

    // New: Personal notes about the technique
    var notes: String?

    // New: Key points to remember
    var keyPoints: [String]

    // New: Common mistakes to avoid
    var commonMistakes: String?

    var sessions: [Session]?

    init(name: String, category: TechniqueCategory) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.useCount = 0
        self.lastUsed = nil
        self.proficiencyRating = 0
        self.notes = nil
        self.keyPoints = []
        self.commonMistakes = nil
    }

    func recordUse() {
        useCount += 1
        lastUsed = Date()
    }

    var ratingStars: String {
        if proficiencyRating == 0 { return "Not rated" }
        return String(repeating: "★", count: proficiencyRating) + String(repeating: "☆", count: 5 - proficiencyRating)
    }
}
