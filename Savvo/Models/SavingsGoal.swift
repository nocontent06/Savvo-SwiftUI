import Foundation

/// Represents a single savings goal with all related state.
struct SavingsGoal: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var emoji: String
    var targetAmount: Double
    var startingAmount: Double
    var targetDate: Date
    var deposits: [Deposit]
    var createdAt: Date
    var reminderEnabled: Bool
    /// Day of the week for the reminder (1 = Sunday, 2 = Monday, …, 7 = Saturday)
    var reminderWeekday: Int
    var reminderHour: Int
    var reminderMinute: Int

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String = "🎯",
        targetAmount: Double,
        startingAmount: Double = 0,
        targetDate: Date,
        deposits: [Deposit] = [],
        createdAt: Date = Date(),
        reminderEnabled: Bool = true,
        reminderWeekday: Int = 2,
        reminderHour: Int = 10,
        reminderMinute: Int = 0
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.targetAmount = targetAmount
        self.startingAmount = startingAmount
        self.targetDate = targetDate
        self.deposits = deposits
        self.createdAt = createdAt
        self.reminderEnabled = reminderEnabled
        self.reminderWeekday = reminderWeekday
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
    }

    // MARK: - Computed Properties

    /// Total amount saved (starting amount + all deposits).
    var savedAmount: Double {
        startingAmount + deposits.reduce(0) { $0 + $1.amount }
    }

    /// Progress as a fraction between 0 and 1.
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(savedAmount / targetAmount, 1.0)
    }

    /// How much still needs to be saved.
    var remainingAmount: Double {
        max(targetAmount - savedAmount, 0)
    }

    /// Number of whole calendar months between today and the target date.
    var monthsRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        guard targetDate > now else { return 0 }
        let components = calendar.dateComponents([.month], from: now, to: targetDate)
        return max(components.month ?? 0, 0)
    }

    /// Amount required per month to reach the goal on time.
    var monthlyNeeded: Double {
        let months = monthsRemaining
        guard months > 0 else { return remainingAmount }
        return remainingAmount / Double(months)
    }

    /// Set of milestone percentages that have been reached (25, 50, 75, 100).
    var reachedMilestones: Set<Int> {
        var milestones = Set<Int>()
        let pct = progress * 100
        for m in [25, 50, 75, 100] where pct >= Double(m) {
            milestones.insert(m)
        }
        return milestones
    }

    /// The highest milestone percentage reached, or nil if none.
    var highestMilestone: Int? {
        reachedMilestones.max()
    }

    // MARK: - Hashable / Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SavingsGoal, rhs: SavingsGoal) -> Bool {
        lhs.id == rhs.id
    }
}
