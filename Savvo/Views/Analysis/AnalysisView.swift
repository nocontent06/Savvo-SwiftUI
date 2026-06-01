import SwiftUI

struct AnalysisView: View {
    @EnvironmentObject var store: GoalsStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summarySection
                    goalsBreakdownSection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Analysis")
        }
    }

    // MARK: - Summary Cards

    private var summarySection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            AnalysisStatCard(
                title: "Gesamt gespart",
                value: store.totalSaved.euroFormatted,
                icon: "banknote.fill",
                color: AppColors.primary
            )
            AnalysisStatCard(
                title: "Aktive Ziele",
                value: "\(store.goals.count)",
                icon: "target",
                color: AppColors.accent
            )
            AnalysisStatCard(
                title: "Ziele erreicht",
                value: "\(store.goals.filter { $0.progress >= 1.0 }.count)",
                icon: "checkmark.seal.fill",
                color: .green
            )
            AnalysisStatCard(
                title: "Ø Fortschritt",
                value: store.goals.isEmpty ? "–" : "\(Int(store.goals.map(\.progress).reduce(0, +) / Double(store.goals.count) * 100)) %",
                icon: "chart.bar.fill",
                color: .purple
            )
        }
    }

    // MARK: - Goals Breakdown

    private var goalsBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zielfortschritt")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            if store.goals.isEmpty {
                Text("Noch keine Ziele vorhanden.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(store.goals) { goal in
                    GoalProgressRow(goal: goal)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Supporting Views

private struct AnalysisStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

private struct GoalProgressRow: View {
    let goal: SavingsGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(goal.emoji)
                    .font(.system(size: 16))
                Text(goal.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Spacer()
                Text("\(Int(goal.progress * 100)) %")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.primary)
                        .frame(width: geo.size.width * min(goal.progress, 1.0), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }
}
