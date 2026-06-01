import SwiftUI
import Charts

struct SavingsPlanChartView: View {
    let goal: SavingsGoal
    let style: ProgressChartStyle

    private struct DataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let cumulative: Double
        let label: String
    }

    private var dataPoints: [DataPoint] {
        let sorted = goal.deposits.sorted { $0.date < $1.date }
        var cumulative = goal.startingAmount
        var points: [DataPoint] = []
        if goal.startingAmount > 0 {
            points.append(DataPoint(
                date: goal.createdAt,
                cumulative: goal.startingAmount,
                label: "Start"
            ))
        }
        for deposit in sorted {
            cumulative += deposit.amount
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yy"
            points.append(DataPoint(
                date: deposit.date,
                cumulative: cumulative,
                label: formatter.string(from: deposit.date)
            ))
        }
        return points
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sparentwicklung")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .padding(.horizontal, 16)

            if dataPoints.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("Noch keine Einzahlungen für den Graphen")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
            } else {
                Chart {
                    ForEach(dataPoints) { point in
                        if style == .bar {
                            BarMark(
                                x: .value("Datum", point.date, unit: .month),
                                y: .value("Gespart", point.cumulative)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.primary.opacity(0.6), AppColors.primary],
                                    startPoint: .bottom, endPoint: .top
                                )
                            )
                            .cornerRadius(4)
                        } else {
                            LineMark(
                                x: .value("Datum", point.date, unit: .month),
                                y: .value("Gespart", point.cumulative)
                            )
                            .foregroundStyle(AppColors.primary)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                            AreaMark(
                                x: .value("Datum", point.date, unit: .month),
                                y: .value("Gespart", point.cumulative)
                            )
                            .foregroundStyle(AppColors.primary.opacity(0.12))
                            PointMark(
                                x: .value("Datum", point.date, unit: .month),
                                y: .value("Gespart", point.cumulative)
                            )
                            .foregroundStyle(AppColors.primary)
                            .symbolSize(30)
                        }
                    }
                    RuleMark(y: .value("Ziel", goal.targetAmount))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                        .foregroundStyle(AppColors.accent)
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Ziel")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.accent)
                        }
                }
                .chartXAxis {
                    AxisMarks(
                        values: .stride(by: .month, count: max(dataPoints.count / 4, 1))
                    ) { _ in
                        AxisValueLabel(
                            format: .dateTime.month(.abbreviated).year(.twoDigits)
                        )
                        .font(.system(size: 9, design: .rounded))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(v.euroFormattedCompact)
                                    .font(.system(size: 9, design: .rounded))
                            }
                        }
                    }
                }
                .frame(height: 180)
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}
