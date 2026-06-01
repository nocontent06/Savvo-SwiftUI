import SwiftUI
import Charts

struct OnboardingSavingsPlanPreview: View {
    let goalName: String
    let emoji: String
    let targetAmount: Double
    let targetDate: Date
    let onFinish: (SavingsGoal) -> Void
    let onBack: () -> Void

    private var months: Int {
        max(Calendar.current.dateComponents([.month], from: Date(), to: targetDate).month ?? 1, 1)
    }

    private var monthlyAmount: Double {
        guard months > 0 else { return targetAmount }
        return targetAmount / Double(months)
    }

    private var chartData: [(month: Int, amount: Double)] {
        (0...months).map { m in (month: m, amount: Double(m) * monthlyAmount) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(emoji)
                        .font(.system(size: 60))
                    Text("Dein Sparplan")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    Text(goalName)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)

                // Stats row
                HStack(spacing: 0) {
                    PlanStatItem(label: "Sparziel", value: targetAmount.euroFormatted, color: AppColors.primary)
                    Divider().frame(height: 40)
                    PlanStatItem(label: "Pro Monat", value: monthlyAmount.euroFormatted, color: AppColors.accent)
                    Divider().frame(height: 40)
                    PlanStatItem(label: "Laufzeit", value: "\(months) Mon.", color: .blue)
                }
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                .padding(.horizontal, 20)

                // Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sparfortschritt")
                        .font(.system(size: 16, weight: .bold, design: .rounded))

                    Chart {
                        ForEach(chartData, id: \.month) { point in
                            BarMark(
                                x: .value("Monat", point.month),
                                y: .value("Betrag", point.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.primary.opacity(0.7), AppColors.primary],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(4)
                        }
                        RuleMark(y: .value("Ziel", targetAmount))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                            .foregroundStyle(AppColors.accent)
                            .annotation(position: .top, alignment: .trailing) {
                                Text("Ziel: \(targetAmount.euroFormattedCompact)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.accent)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.accent.opacity(0.12))
                                    .cornerRadius(6)
                            }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: max(months / 4, 1))) { value in
                            AxisValueLabel {
                                if let m = value.as(Int.self) {
                                    Text("M\(m)")
                                        .font(.system(size: 10, design: .rounded))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let v = value.as(Double.self) {
                                    Text(v.euroFormattedCompact)
                                        .font(.system(size: 10, design: .rounded))
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                .padding(.horizontal, 20)

                // Motivational message
                HStack(spacing: 12) {
                    Text("💡")
                        .font(.system(size: 24))
                    Text("Mit nur \(monthlyAmount.euroFormatted) pro Monat erreichst du dein Ziel in \(months) Monaten!")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(AppColors.primary.opacity(0.08))
                .cornerRadius(16)
                .padding(.horizontal, 20)

                // CTA
                Button {
                    let goal = SavingsGoal(
                        name: goalName,
                        emoji: emoji,
                        targetAmount: targetAmount,
                        targetDate: targetDate
                    )
                    onFinish(goal)
                } label: {
                    HStack(spacing: 10) {
                        Text("Sparplan starten!")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(AppColors.primary)
                    .cornerRadius(20)
                    .shadow(color: AppColors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 20)

                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Zurück")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

private struct PlanStatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
