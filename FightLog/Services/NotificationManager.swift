import Foundation
import UserNotifications
import SwiftData

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private init() {
        Task {
            await checkAuthorization()
        }
    }

    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await checkAuthorization()
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    func scheduleTrainingReminders(schedule: TrainingSchedule, sessions: [Session]) {
        // Cancel all existing reminders first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard schedule.notificationsEnabled else { return }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: schedule.notificationTime)
        let minute = calendar.component(.minute, from: schedule.notificationTime)

        // Schedule notifications for each training day
        for weekday in schedule.scheduledDays {
            // Check if user already trained today (if it's the current weekday)
            let today = calendar.component(.weekday, from: Date())
            if weekday == today {
                let hasTrainedToday = sessions.contains { session in
                    calendar.isDateInToday(session.timestamp)
                }
                if hasTrainedToday {
                    continue // Skip today's reminder if already trained
                }
            }

            var dateComponents = DateComponents()
            dateComponents.weekday = weekday
            dateComponents.hour = hour
            dateComponents.minute = minute

            let content = UNMutableNotificationContent()
            content.title = "Training Day!"
            content.body = "Did you train today? Don't forget to log your session."
            content.sound = .default
            content.badge = 1

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "training-reminder-\(weekday)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
