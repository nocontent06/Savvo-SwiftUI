import UserNotifications
import Foundation

/// Manages all local push notifications for Savvo.
final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    self.scheduleWeeklyGlobalMotivation()
                }
            }
        }
    }

    // MARK: - Global Weekly Motivation

    private func scheduleWeeklyGlobalMotivation() {
        let content = UNMutableNotificationContent()
        content.title = "Zeit zum Sparen! 💰"
        content.body = "Schau dir deine Sparziele an und leg heute was zurück."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: "savvo_global_weekly",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Per-Goal Weekly Reminder

    func scheduleWeeklyReminder(for goal: SavingsGoal) {
        let content = UNMutableNotificationContent()
        content.title = "Zeit zum Sparen! 🎯"
        content.body = "Dein Ziel '\(goal.name)' wartet auf dich."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = goal.reminderWeekday
        dateComponents.hour = goal.reminderHour
        dateComponents.minute = goal.reminderMinute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: notificationId(for: goal.id),
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Milestone Notification

    func scheduleMilestoneNotification(goalName: String, milestone: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Meilenstein erreicht!"
        content.body = "Du hast \(milestone) % deines Ziels '\(goalName)' erreicht!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "savvo_milestone_\(goalName)_\(milestone)_\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel

    func cancelNotifications(for goalId: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationId(for: goalId)])
    }

    // MARK: - Private

    private func notificationId(for goalId: UUID) -> String {
        "savvo_goal_\(goalId.uuidString)"
    }
}
