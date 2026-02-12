import SwiftUI
import SwiftData

struct TrainingScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var schedules: [TrainingSchedule]
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]

    @StateObject private var notificationManager = NotificationManager.shared

    private var schedule: TrainingSchedule {
        if let existing = schedules.first {
            return existing
        }
        let newSchedule = TrainingSchedule()
        modelContext.insert(newSchedule)
        return newSchedule
    }

    private let weekdays = [
        (2, "Monday", "M"),
        (3, "Tuesday", "T"),
        (4, "Wednesday", "W"),
        (5, "Thursday", "T"),
        (6, "Friday", "F"),
        (7, "Saturday", "S"),
        (1, "Sunday", "S")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Training Days Selection
                    trainingDaysSection

                    // This Week Overview
                    thisWeekSection

                    // Notification Settings
                    notificationSection

                    // Stats
                    statsSection
                }
                .padding()
            }
            .premiumBackground()
            .navigationTitle("Training Schedule")
        }
    }

    private var trainingDaysSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Days")
                .font(.headline)

            Text("Select which days you usually train")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(weekdays, id: \.0) { weekday, _, short in
                    DayToggleButton(
                        day: short,
                        isSelected: schedule.isScheduledDay(weekday),
                        action: {
                            schedule.toggleDay(weekday)
                            updateNotifications()
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var thisWeekSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(thisWeekDays(), id: \.date) { dayInfo in
                    WeekDayCell(
                        day: dayInfo.shortName,
                        date: dayInfo.dayNumber,
                        isScheduled: dayInfo.isScheduled,
                        isCompleted: dayInfo.hasSession,
                        isToday: dayInfo.isToday
                    )
                }
            }

            // Weekly progress
            let completed = thisWeekDays().filter { $0.hasSession }.count
            let scheduled = thisWeekDays().filter { $0.isScheduled }.count

            HStack {
                Text("\(completed) of \(scheduled) scheduled sessions completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if completed >= scheduled && scheduled > 0 {
                    Label("Goal met!", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reminders")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { schedule.notificationsEnabled },
                    set: { newValue in
                        Task {
                            if newValue {
                                let authorized = await notificationManager.requestAuthorization()
                                if authorized {
                                    schedule.notificationsEnabled = true
                                    updateNotifications()
                                }
                            } else {
                                schedule.notificationsEnabled = false
                                notificationManager.cancelAllReminders()
                            }
                        }
                    }
                ))
                .labelsHidden()
            }

            if schedule.notificationsEnabled {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.orange)
                    Text("Reminder at")
                        .foregroundStyle(.secondary)
                    Spacer()
                    DatePicker("", selection: Binding(
                        get: { schedule.notificationTime },
                        set: { newValue in
                            schedule.notificationTime = newValue
                            updateNotifications()
                        }
                    ), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                }

                Text("You'll get a reminder on training days if you haven't logged a session yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Enable to get reminded to log your training on scheduled days.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Consistency")
                .font(.headline)

            let lastFourWeeks = consistencyStats()

            HStack(spacing: 16) {
                StatBox(title: "This Month", value: "\(lastFourWeeks.percentage)%", icon: "percent")
                StatBox(title: "Sessions", value: "\(lastFourWeeks.completed)/\(lastFourWeeks.scheduled)", icon: "checkmark.circle")
            }

            if lastFourWeeks.percentage >= 80 {
                Label("Great consistency! Keep it up!", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else if lastFourWeeks.percentage >= 50 {
                Label("Good progress! Try to hit more scheduled days.", systemImage: "hand.thumbsup.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func thisWeekDays() -> [DayInfo] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
            let weekday = calendar.component(.weekday, from: date)
            let dayNumber = calendar.component(.day, from: date)
            let isToday = calendar.isDateInToday(date)
            let hasSession = sessions.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
            let shortName = ["S", "M", "T", "W", "T", "F", "S"][weekday - 1]

            return DayInfo(
                date: date,
                weekday: weekday,
                dayNumber: dayNumber,
                shortName: shortName,
                isScheduled: schedule.isScheduledDay(weekday),
                hasSession: hasSession,
                isToday: isToday
            )
        }
    }

    private func consistencyStats() -> (completed: Int, scheduled: Int, percentage: Int) {
        let calendar = Calendar.current
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: Date())!

        var scheduledCount = 0
        var completedCount = 0

        var date = fourWeeksAgo
        while date <= Date() {
            let weekday = calendar.component(.weekday, from: date)
            if schedule.isScheduledDay(weekday) {
                scheduledCount += 1
                if sessions.contains(where: { calendar.isDate($0.timestamp, inSameDayAs: date) }) {
                    completedCount += 1
                }
            }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        let percentage = scheduledCount > 0 ? Int((Double(completedCount) / Double(scheduledCount)) * 100) : 0
        return (completedCount, scheduledCount, percentage)
    }

    private func updateNotifications() {
        notificationManager.scheduleTrainingReminders(schedule: schedule, sessions: sessions)
    }
}

struct DayInfo {
    let date: Date
    let weekday: Int
    let dayNumber: Int
    let shortName: String
    let isScheduled: Bool
    let hasSession: Bool
    let isToday: Bool
}

struct DayToggleButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.subheadline.bold())
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Circle())
        }
    }
}

struct WeekDayCell: View {
    let day: String
    let date: Int
    let isScheduled: Bool
    let isCompleted: Bool
    let isToday: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.caption2)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 36, height: 36)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                } else {
                    Text("\(date)")
                        .font(.caption)
                        .foregroundStyle(isScheduled ? .white : .primary)
                }
            }
            .overlay {
                if isToday {
                    Circle()
                        .stroke(Color.orange, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isScheduled {
            return .orange.opacity(0.6)
        } else {
            return Color(.systemGray5)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
