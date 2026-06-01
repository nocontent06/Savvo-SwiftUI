import Foundation

/// Represents a single deposit into a savings goal.
struct Deposit: Codable, Identifiable, Hashable {
    var id: UUID
    var amount: Double
    var date: Date
    var note: String

    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = Date(),
        note: String = ""
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Deposit, rhs: Deposit) -> Bool {
        lhs.id == rhs.id
    }
}
