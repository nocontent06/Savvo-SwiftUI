import SwiftUI

/// Card representing a single savings goal in the home list.
struct GoalCardView: View {
    let goal: SavingsGoal
    @State private var animateProgress = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // ── Header ──────────────────────────────────────────────
            HStack(alignment: .center, spacing: 12) {
                Text(goal.emoji)
                    .font(.system(size: 38))

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        if let milestone = goal.highestMilestone {
                            MilestoneBadgeView(milestone: milestone)
                        }

                        if goal.monthsRemaining > 0 {
                            Text("\(goal.monthsRemaining) Mon. verbleibend")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        } else {
                            Text("Zieldatum erreicht")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.accent)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            // ── Progress bar ─────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(height: 10)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.primary.opacity(0.75),
                                        AppColors.primary
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * (animateProgress ? goal.progress : 0),
                                height: 10
                            )
                            .animation(
                                .spring(response: 1.0, dampingFraction: 0.8).delay(0.15),
                                value: animateProgress
                            )
                    }
                }
                .frame(height: 10)

                HStack {
                    Text(goal.savedAmount.euroFormatted)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.primary)
                    Spacer()
                    Text(goal.targetAmount.euroFormatted)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            // ── Footer ───────────────────────────────────────────────
            HStack {
                Label("\(goal.monthsRemaining) Monate", systemImage: "calendar")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(goal.monthlyNeeded.euroFormatted)/Monat")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.accent)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .onAppear { animateProgress = true }
        .onDisappear { animateProgress = false }
    }
}
