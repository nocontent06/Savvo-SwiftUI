import SwiftUI

/// Sheet for entering a deposit amount into a savings goal.
struct DepositSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: GoalsStore

    let goalId: UUID
    let goalName: String
    var onMilestone: (Int) -> Void

    @State private var amountText: String = ""
    @State private var note: String = ""

    private var amount: Double {
        amountText.asDouble ?? 0
    }

    private var isValid: Bool { amount > 0 }

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                // ── Icon + title ─────────────────────────────────────
                VStack(spacing: 10) {
                    Text("💰")
                        .font(.system(size: 52))
                    Text("Einzahlung")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("Für: \(goalName)")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)

                // ── Amount input ─────────────────────────────────────
                HStack(alignment: .center, spacing: 6) {
                    Text("€")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primary)

                    TextField("0,00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                .padding(.horizontal)

                // ── Note input ───────────────────────────────────────
                TextField("Notiz (optional)", text: $note)
                    .font(.system(size: 15, design: .rounded))
                    .padding(14)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                // ── Quick-add buttons ─────────────────────────────────
                HStack(spacing: 10) {
                    ForEach([10.0, 25.0, 50.0, 100.0], id: \.self) { quick in
                        Button {
                            let current = amountText.asDouble ?? 0
                            amountText = String(format: "%.2f", current + quick)
                                .replacingOccurrences(of: ".", with: ",")
                        } label: {
                            Text("+€\(Int(quick))")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(AppColors.primary.opacity(0.10))
                                .cornerRadius(20)
                        }
                    }
                }

                Spacer()

                // ── Confirm button ────────────────────────────────────
                Button {
                    performDeposit()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Einzahlen")
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isValid ? AppColors.primary : Color(.systemGray4))
                    .cornerRadius(18)
                    .shadow(color: isValid ? AppColors.primary.opacity(0.35) : .clear,
                            radius: 10, x: 0, y: 5)
                }
                .disabled(!isValid)
                .padding(.horizontal)
                .padding(.bottom, 36)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Einzahlung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }

    private func performDeposit() {
        if let milestone = store.addDeposit(amount: amount, note: note, to: goalId) {
            onMilestone(milestone)
        }
        dismiss()
    }
}
