import Foundation
import Combine

/// Persists and manages all savings goals and user settings.
final class GoalsStore: ObservableObject {

    @Published var goals: [SavingsGoal] = []
    @Published var settings: UserSettings = UserSettings()

    private let goalsKey = "savvo_goals_v1"
    private let settingsKey = "savvo_settings_v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        loadData()
    }

    // MARK: - Persistence

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? decoder.decode([SavingsGoal].self, from: data) {
            goals = decoded
        }
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? decoder.decode(UserSettings.self, from: data) {
            settings = decoded
        }
    }

    func saveData() {
        if let encoded = try? encoder.encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
        if let encoded = try? encoder.encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }

    // MARK: - Goal Management

    func addGoal(_ goal: SavingsGoal) {
        goals.append(goal)
        saveData()
        if goal.reminderEnabled {
            NotificationManager.shared.scheduleWeeklyReminder(for: goal)
        }
    }

    func updateGoal(_ goal: SavingsGoal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index] = goal
        saveData()
        NotificationManager.shared.cancelNotifications(for: goal.id)
        if goal.reminderEnabled {
            NotificationManager.shared.scheduleWeeklyReminder(for: goal)
        }
    }

    func deleteGoal(_ goal: SavingsGoal) {
        goals.removeAll { $0.id == goal.id }
        NotificationManager.shared.cancelNotifications(for: goal.id)
        saveData()
    }

    // MARK: - Deposits

    /// Adds a deposit to the specified goal.
    /// - Returns: The milestone percentage just crossed (25/50/75/100), or `nil` if no milestone was hit.
    @discardableResult
    func addDeposit(amount: Double, note: String = "", to goalId: UUID) -> Int? {
        guard let index = goals.firstIndex(where: { $0.id == goalId }) else { return nil }

        let previousProgress = goals[index].progress
        let deposit = Deposit(amount: amount, note: note)
        goals[index].deposits.append(deposit)
        let newProgress = goals[index].progress

        var newMilestone: Int?
        for milestone in [25, 50, 75, 100] {
            let threshold = Double(milestone)
            if previousProgress * 100 < threshold && newProgress * 100 >= threshold {
                newMilestone = milestone
                NotificationManager.shared.scheduleMilestoneNotification(
                    goalName: goals[index].name,
                    milestone: milestone
                )
            }
        }

        updateStreak()
        saveData()
        return newMilestone
    }

    func deleteDeposit(depositId: UUID, from goalId: UUID) {
        guard let index = goals.firstIndex(where: { $0.id == goalId }) else { return }
        goals[index].deposits.removeAll { $0.id == depositId }
        saveData()
    }

    // MARK: - Computed

    /// Sum of all saved amounts across every goal.
    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.savedAmount }
    }

    /// Motivational message for the current calendar week.
    var weeklyMotivationMessage: String {
        let week = Calendar.current.component(.weekOfYear, from: Date())
        let messages = Constants.motivationalMessages
        return messages[week % messages.count]
    }

    // MARK: - Streak

    private func updateStreak() {
        let calendar = Calendar.current
        let today = Date()

        if let lastDate = settings.lastDepositDate {
            let weeksSince = calendar.dateComponents(
                [.weekOfYear], from: lastDate, to: today
            ).weekOfYear ?? 0

            if weeksSince == 0 {
                // Same week – nothing to change
            } else if weeksSince == 1 {
                settings.streakWeeks += 1
            } else {
                settings.streakWeeks = 1
            }
        } else {
            settings.streakWeeks = 1
        }
        settings.lastDepositDate = today
        saveData()
    }
}

// MARK: - UserSettings

struct UserSettings: Codable {
    var firstName: String = ""
    var streakWeeks: Int = 0
    var lastDepositDate: Date?
}
