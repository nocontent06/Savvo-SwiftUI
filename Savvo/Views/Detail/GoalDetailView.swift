import SwiftUI

/// Detail screen for a single savings goal.
struct GoalDetailView: View {
    @EnvironmentObject var store: GoalsStore
    @Environment(\.dismiss) private var dismiss

    /// Initial value used to look up the live goal from the store.
    let goal: SavingsGoal

    @State private var showDeposit = false
    @State private var showConfetti = false
    @State private var showEdit = false
    @State private var showDeleteAlert = false
    @State private var milestonePercent: Int = 0
    @State private var showMilestoneAlert = false

    /// Always reads the freshest data from the store.
    private var current: SavingsGoal {
        store.goals.first { $0.id == goal.id } ?? goal
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroSection
                    statsGrid
                    depositButton
                    milestonesSection
                    depositHistorySection
                }
                .padding(.bottom, 48)
            }
            .background(AppColors.background.ignoresSafeArea())

            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            showConfetti = false
                        }
                    }
            }
        }
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showDeposit) {
            DepositSheetView(goalId: current.id, goalName: current.name) { milestone in
                milestonePercent = milestone
                showConfetti = true
                showMilestoneAlert = true
            }
        }
        .sheet(isPresented: $showEdit) {
            AddEditGoalView(existingGoal: current)
        }
        .alert("Ziel löschen?", isPresented: $showDeleteAlert) {
            Button("Löschen", role: .destructive) {
                store.deleteGoal(goal)
                dismiss()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Alle Einzahlungen für '\(current.name)' werden ebenfalls gelöscht.")
        }
        .alert("🎉 \(milestonePercent) % erreicht!", isPresented: $showMilestoneAlert) {
            Button("Super! 🎉") {}
        } message: {
            Text("Weiter so! Du kommst deinem Ziel immer näher.")
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var heroSection: some View {
        VStack(spacing: 20) {
            Text(current.emoji)
                .font(.system(size: 76))
                .padding(.top, 12)

            CircularProgressView(progress: current.progress, size: 168)
        }
    }

    @ViewBuilder
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            StatCardView(
                title: "Gespart",
                value: current.savedAmount.euroFormatted,
                icon: "checkmark.circle.fill",
                color: AppColors.primary
            )
            StatCardView(
                title: "Verbleibend",
                value: current.remainingAmount.euroFormatted,
                icon: "target",
                color: AppColors.accent
            )
            StatCardView(
                title: "Pro Monat",
                value: current.monthlyNeeded.euroFormatted,
                icon: "calendar",
                color: .blue
            )
            StatCardView(
                title: "Monate verbleibend",
                value: "\(current.monthsRemaining)",
                icon: "clock.fill",
                color: .purple
            )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var depositButton: some View {
        Button {
            showDeposit = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                Text("Einzahlung vornehmen")
            }
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppColors.primary)
            .cornerRadius(18)
            .shadow(color: AppColors.primary.opacity(0.35), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
        .accessibilityLabel("Einzahlung für \(current.name) vornehmen")
    }

    @ViewBuilder
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meilensteine")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.horizontal)

            HStack(spacing: 10) {
                ForEach([25, 50, 75, 100], id: \.self) { milestone in
                    let reached = current.reachedMilestones.contains(milestone)
                    VStack(spacing: 6) {
                        MilestoneBadgeView(milestone: milestone)
                        Text(reached ? "Erreicht!" : "\(milestone) %")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(reached ? AppColors.primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .opacity(reached ? 1 : 0.45)
                    .shadow(color: .black.opacity(reached ? 0.06 : 0), radius: 6, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var depositHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Einzahlungen")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.horizontal)

            if current.deposits.isEmpty {
                Text("Noch keine Einzahlungen")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(current.deposits.sorted(by: { $0.date > $1.date })) { deposit in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(deposit.date.germanFormatted)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                if !deposit.note.isEmpty {
                                    Text(deposit.note)
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text("+ \(deposit.amount.euroFormatted)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(14)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                store.deleteDeposit(depositId: deposit.id, from: current.id)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    showEdit = true
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Löschen", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(AppColors.primary)
            }
        }
    }
}
