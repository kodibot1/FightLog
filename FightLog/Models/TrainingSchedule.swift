import Foundation
import SwiftData

@Model
final class TrainingSchedule {
    var id: UUID
    var monday: Bool
    var tuesday: Bool
    var wednesday: Bool
    var thursday: Bool
    var friday: Bool
    var saturday: Bool
    var sunday: Bool
    var notificationTime: Date  // Time of day to send reminder
    var notificationsEnabled: Bool

    init() {
        self.id = UUID()
        // Default to training on Mon, Wed, Fri
        self.monday = true
        self.tuesday = false
        self.wednesday = true
        self.thursday = false
        self.friday = true
        self.saturday = false
        self.sunday = false

        // Default notification time: 8 PM
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        self.notificationTime = Calendar.current.date(from: components) ?? Date()
        self.notificationsEnabled = false
    }

    var scheduledDays: [Int] {
        // Returns weekday numbers (1 = Sunday, 2 = Monday, etc.)
        var days: [Int] = []
        if sunday { days.append(1) }
        if monday { days.append(2) }
        if tuesday { days.append(3) }
        if wednesday { days.append(4) }
        if thursday { days.append(5) }
        if friday { days.append(6) }
        if saturday { days.append(7) }
        return days
    }

    var scheduledDayNames: [String] {
        var names: [String] = []
        if monday { names.append("Mon") }
        if tuesday { names.append("Tue") }
        if wednesday { names.append("Wed") }
        if thursday { names.append("Thu") }
        if friday { names.append("Fri") }
        if saturday { names.append("Sat") }
        if sunday { names.append("Sun") }
        return names
    }

    func isScheduledDay(_ weekday: Int) -> Bool {
        switch weekday {
        case 1: return sunday
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        default: return false
        }
    }

    func toggleDay(_ weekday: Int) {
        switch weekday {
        case 1: sunday.toggle()
        case 2: monday.toggle()
        case 3: tuesday.toggle()
        case 4: wednesday.toggle()
        case 5: thursday.toggle()
        case 6: friday.toggle()
        case 7: saturday.toggle()
        default: break
        }
    }
}
