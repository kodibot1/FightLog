import Foundation
import SwiftData

/// Boxing number system reference:
/// 1 = Jab
/// 2 = Cross
/// 3 = Lead Hook
/// 4 = Rear Hook
/// 5 = Lead Uppercut
/// 6 = Rear Uppercut
/// 7 = Lead Body Hook
/// 8 = Rear Body Hook
/// b = Body (modifier, e.g., 1b = Body Jab)

@Model
final class Combo {
    var id: UUID
    var numbers: String  // e.g., "1-2-3-2", "1-2-5-2"
    var name: String?    // Optional custom name like "The Philly Shell Counter"
    var notes: String?   // Tips or details about the combo
    var useCount: Int
    var lastUsed: Date?
    var isCustom: Bool   // User-created vs default

    var sessions: [Session]?

    init(numbers: String, name: String? = nil, notes: String? = nil, isCustom: Bool = false) {
        self.id = UUID()
        self.numbers = numbers
        self.name = name
        self.notes = notes
        self.useCount = 0
        self.lastUsed = nil
        self.isCustom = isCustom
    }

    func recordUse() {
        useCount += 1
        lastUsed = Date()
    }

    /// Returns human-readable breakdown of the combo
    var breakdown: String {
        let parts = numbers.replacingOccurrences(of: "-", with: " ").split(separator: " ")
        return parts.map { numberToName(String($0)) }.joined(separator: " → ")
    }

    private func numberToName(_ num: String) -> String {
        switch num.lowercased() {
        case "1": return "Jab"
        case "2": return "Cross"
        case "3": return "Lead Hook"
        case "4": return "Rear Hook"
        case "5": return "Lead Uppercut"
        case "6": return "Rear Uppercut"
        case "7": return "Lead Body Hook"
        case "8": return "Rear Body Hook"
        case "1b": return "Body Jab"
        case "2b": return "Body Cross"
        case "k", "lk": return "Low Kick"
        case "t": return "Teep"
        case "rh": return "Roundhouse"
        default: return num
        }
    }

    var displayName: String {
        name ?? numbers
    }
}
