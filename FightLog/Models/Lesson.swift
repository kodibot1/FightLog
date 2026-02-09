import Foundation
import SwiftData

/// A lesson/workout that can be shared with friends and family
/// Compiles techniques, combos, and drills into a teachable format
@Model
final class Lesson {
    var id: UUID
    var title: String
    var notes: String?
    var difficulty: LessonDifficulty
    var durationMinutes: Int
    var createdAt: Date
    var updatedAt: Date

    // Lesson content
    var warmupNotes: String?
    var drills: [LessonDrill]
    var exercises: [ExerciseSlot]
    var cooldownNotes: String?

    // Source session (optional - if created from a session)
    var sourceSession: Session?

    init(
        title: String,
        notes: String? = nil,
        difficulty: LessonDifficulty = .beginner,
        durationMinutes: Int = 30,
        warmupNotes: String? = nil,
        drills: [LessonDrill] = [],
        exercises: [ExerciseSlot] = [],
        cooldownNotes: String? = nil,
        sourceSession: Session? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.difficulty = difficulty
        self.durationMinutes = durationMinutes
        self.createdAt = Date()
        self.updatedAt = Date()
        self.warmupNotes = warmupNotes
        self.drills = drills
        self.exercises = exercises
        self.cooldownNotes = cooldownNotes
        self.sourceSession = sourceSession
    }

    /// Generate shareable text version of the lesson
    var shareableText: String {
        var text = "🥊 \(title)\n"
        text += "━━━━━━━━━━━━━━━━━━━━\n"
        text += "⏱ \(durationMinutes) minutes | \(difficulty.rawValue)\n\n"

        if let notes = notes, !notes.isEmpty {
            text += "📝 \(notes)\n\n"
        }

        if let warmup = warmupNotes, !warmup.isEmpty {
            text += "🔥 WARMUP\n\(warmup)\n\n"
        }

        if !drills.isEmpty {
            text += "💪 DRILLS\n"
            for (index, drill) in drills.enumerated() {
                text += "\(index + 1). \(drill.title)\n"
                if let combo = drill.comboNumbers {
                    text += "   Combo: \(combo)\n"
                }
                if let reps = drill.reps {
                    text += "   Reps: \(reps)\n"
                }
                if let rounds = drill.rounds, let roundTime = drill.roundTimeSeconds {
                    text += "   \(rounds) rounds × \(roundTime/60):\(String(format: "%02d", roundTime%60))\n"
                }
                if let notes = drill.notes, !notes.isEmpty {
                    text += "   💡 \(notes)\n"
                }
                text += "\n"
            }
        }

        if !exercises.isEmpty {
            text += "🏋️ EXERCISES\n"
            for (index, exercise) in exercises.enumerated() {
                text += "\(index + 1). \(exercise.category.icon) \(exercise.name)"
                if let sets = exercise.sets, let reps = exercise.reps {
                    text += " — \(sets) sets × \(reps) reps"
                } else if let duration = exercise.durationSeconds {
                    let mins = duration / 60
                    text += " — \(mins) min"
                }
                if let equipment = exercise.equipment {
                    text += " [\(equipment)]"
                }
                if let rest = exercise.restSeconds, rest > 0 {
                    text += " (rest: \(rest)s)"
                }
                if let notes = exercise.notes, !notes.isEmpty {
                    text += "\n   💡 \(notes)"
                }
                text += "\n"
            }
            text += "\n"
        }

        if let cooldown = cooldownNotes, !cooldown.isEmpty {
            text += "🧘 COOLDOWN\n\(cooldown)\n"
        }

        text += "\n━━━━━━━━━━━━━━━━━━━━\n"
        text += "Created with FightLog"

        return text
    }
}

enum LessonDifficulty: String, Codable, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        }
    }
}

/// A general exercise slot within a lesson (warmup, strength, conditioning, etc.)
struct ExerciseSlot: Codable, Identifiable {
    var id: UUID
    var name: String
    var category: ExerciseCategory
    var equipment: String?
    var sets: Int?
    var reps: Int?
    var durationSeconds: Int?
    var restSeconds: Int?
    var notes: String?

    init(
        name: String,
        category: ExerciseCategory = .warmup,
        equipment: String? = nil,
        sets: Int? = nil,
        reps: Int? = nil,
        durationSeconds: Int? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.equipment = equipment
        self.sets = sets
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.restSeconds = restSeconds
        self.notes = notes
    }
}

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case warmup = "Warmup"
    case boxing = "Boxing"
    case strength = "Strength"
    case conditioning = "Conditioning"
    case cooldown = "Cooldown"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .warmup: return "flame.fill"
        case .boxing: return "figure.boxing"
        case .strength: return "dumbbell.fill"
        case .conditioning: return "bolt.fill"
        case .cooldown: return "wind"
        }
    }
}

/// A single drill within a lesson
struct LessonDrill: Codable, Identifiable {
    var id: UUID
    var title: String
    var comboNumbers: String?  // e.g., "1-2-3-2"
    var techniqueNames: [String]?
    var reps: Int?
    var rounds: Int?
    var roundTimeSeconds: Int?
    var restTimeSeconds: Int?
    var notes: String?

    init(
        title: String,
        comboNumbers: String? = nil,
        techniqueNames: [String]? = nil,
        reps: Int? = nil,
        rounds: Int? = nil,
        roundTimeSeconds: Int? = nil,
        restTimeSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.comboNumbers = comboNumbers
        self.techniqueNames = techniqueNames
        self.reps = reps
        self.rounds = rounds
        self.roundTimeSeconds = roundTimeSeconds
        self.restTimeSeconds = restTimeSeconds
        self.notes = notes
    }
}
