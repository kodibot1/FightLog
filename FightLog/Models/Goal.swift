import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var title: String
    var targetCount: Int  // e.g., "Train 3 times"
    var period: GoalPeriod
    var createdAt: Date
    var isActive: Bool

    init(title: String, targetCount: Int, period: GoalPeriod) {
        self.id = UUID()
        self.title = title
        self.targetCount = targetCount
        self.period = period
        self.createdAt = Date()
        self.isActive = true
    }
}

enum GoalPeriod: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        }
    }
}

@Model
final class Streak {
    var id: UUID
    var currentStreak: Int
    var longestStreak: Int
    var lastTrainingDate: Date?

    init() {
        self.id = UUID()
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastTrainingDate = nil
    }

    func updateStreak(with sessionDate: Date) {
        let calendar = Calendar.current

        if let lastDate = lastTrainingDate {
            let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: sessionDate)).day ?? 0

            if daysBetween == 1 {
                // Consecutive day - extend streak
                currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken - reset
                currentStreak = 1
            }
            // daysBetween == 0 means same day, don't change streak
        } else {
            // First training ever
            currentStreak = 1
        }

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        lastTrainingDate = sessionDate
    }

    func checkStreakStatus() {
        guard let lastDate = lastTrainingDate else { return }

        let calendar = Calendar.current
        let daysSinceLastTraining = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: Date())).day ?? 0

        if daysSinceLastTraining > 1 {
            // Streak is broken
            currentStreak = 0
        }
    }
}
