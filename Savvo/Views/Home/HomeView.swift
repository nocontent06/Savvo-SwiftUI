import SwiftUI

/// The main home screen listing all savings goals.
struct HomeView: View {
    @EnvironmentObject var store: GoalsStore
    @State private var showAddGoal = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {

                // ── Content ──────────────────────────────────────────
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                            .padding(.horizontal)
                            .padding(.top, 8)

                        MotivationCardView(
                            message: store.weeklyMotivationMessage,
                            streakWeeks: store.settings.streakWeeks
                        )
                        .padding(.horizontal)

                        if store.goals.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(store.goals) { goal in
                                    NavigationLink(value: goal) {
                                        GoalCardView(goal: goal)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        Spacer(minLength: 96)
                    }
                    .padding(.bottom, 8)
                }
                .background(AppColors.background.ignoresSafeArea())

                // ── Floating Action Button ────────────────────────────
                Button {
                    showAddGoal = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 62, height: 62)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                        .shadow(color: AppColors.primary.opacity(0.38), radius: 14, x: 0, y: 6)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 32)
                .accessibilityLabel("Neues Sparziel hinzufügen")
            }
            .navigationBarHidden(true)
            .navigationDestination(for: SavingsGoal.self) { goal in
                GoalDetailView(goal: goal)
            }
        }
        .sheet(isPresented: $showAddGoal) {
            AddEditGoalView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            if store.settings.firstName.isEmpty {
                showSettings = true
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(store.settings.firstName.isEmpty
                     ? "Hallo! 👋"
                     : "Hallo, \(store.settings.firstName)! 👋")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                if !store.goals.isEmpty {
                    Text("Gesamt gespart: \(store.totalSaved.euroFormatted)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.primary)
                }
            }

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.primary)
            }
            .accessibilityLabel("Einstellungen öffnen")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 18) {
            Text("💰")
                .font(.system(size: 76))
                .padding(.top, 48)

            Text("Noch kein Sparziel")
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text("Tippe auf +, um dein erstes\nSparziel anzulegen!")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
}
