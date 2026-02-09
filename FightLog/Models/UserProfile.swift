import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var username: String
    var primaryGoal: TrainingGoal
    var weeklyTarget: Int
    var createdAt: Date

    // Onboarding context for AI
    var disciplines: [MartialArtDiscipline]
    var experienceLevel: ExperienceLevel

    // Smart defaults from onboarding hints
    var typicalSessionLength: Int
    var preferredSessionType: SessionType
    var preferredIntensity: Intensity

    init(
        username: String,
        primaryGoal: TrainingGoal = .fitness,
        weeklyTarget: Int = 3,
        disciplines: [MartialArtDiscipline] = [.boxing],
        experienceLevel: ExperienceLevel = .beginner,
        typicalSessionLength: Int = 60,
        preferredSessionType: SessionType = .classSession,
        preferredIntensity: Intensity = .moderate
    ) {
        self.id = UUID()
        self.username = username
        self.primaryGoal = primaryGoal
        self.weeklyTarget = weeklyTarget
        self.disciplines = disciplines
        self.experienceLevel = experienceLevel
        self.typicalSessionLength = typicalSessionLength
        self.preferredSessionType = preferredSessionType
        self.preferredIntensity = preferredIntensity
        self.createdAt = Date()
    }

    /// Builds a context string for AI features
    var aiContext: String {
        var ctx = "Fighter profile:"
        ctx += "\n- Name: \(username)"
        ctx += "\n- Disciplines: \(disciplines.map { $0.rawValue }.joined(separator: ", "))"
        ctx += "\n- Experience: \(experienceLevel.rawValue)"
        ctx += "\n- Goal: \(primaryGoal.rawValue)"
        ctx += "\n- Training frequency: \(weeklyTarget)x per week"
        ctx += "\n- Typical session: \(typicalSessionLength) min \(preferredSessionType.rawValue) at \(preferredIntensity.rawValue) intensity"
        return ctx
    }
}

enum TrainingGoal: String, Codable, CaseIterable, Identifiable {
    case fitness = "General Fitness"
    case competition = "Competition Prep"
    case selfDefense = "Self Defense"
    case fun = "Fun & Stress Relief"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fitness: return "figure.run"
        case .competition: return "trophy.fill"
        case .selfDefense: return "shield.fill"
        case .fun: return "face.smiling.fill"
        }
    }

    var emoji: String {
        switch self {
        case .fitness: return "💪"
        case .competition: return "🏆"
        case .selfDefense: return "🛡️"
        case .fun: return "😄"
        }
    }

    var subtitle: String {
        switch self {
        case .fitness: return "Stay sharp & in shape"
        case .competition: return "Train to compete"
        case .selfDefense: return "Learn to protect yourself"
        case .fun: return "Enjoy the art"
        }
    }
}

enum MartialArtDiscipline: String, Codable, CaseIterable, Identifiable {
    case boxing = "Boxing"
    case muayThai = "Muay Thai"
    case mma = "MMA"
    case bjj = "BJJ"
    case kickboxing = "Kickboxing"
    case wrestling = "Wrestling"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .boxing: return "🥊"
        case .muayThai: return "🦵"
        case .mma: return "🤼"
        case .bjj: return "🥋"
        case .kickboxing: return "👊"
        case .wrestling: return "💪"
        }
    }
}

enum ExperienceLevel: String, Codable, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case pro = "Pro"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .beginner: return "🌱"
        case .intermediate: return "🔥"
        case .advanced: return "⚡"
        case .pro: return "🏅"
        }
    }

    var subtitle: String {
        switch self {
        case .beginner: return "Less than 1 year"
        case .intermediate: return "1–3 years"
        case .advanced: return "3+ years"
        case .pro: return "Competing regularly"
        }
    }
}
