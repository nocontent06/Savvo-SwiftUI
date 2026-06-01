import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: GoalsStore
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    avatarSection
                    statsSection
                    actionsSection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 88, height: 88)
                Text(store.settings.firstName.isEmpty ? "?" : String(store.settings.firstName.prefix(1)).uppercased())
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primary)
            }

            Text(store.settings.firstName.isEmpty ? "Dein Name" : store.settings.firstName)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 13))
                Text(store.settings.streakWeeks == 1
                     ? "1 Woche Streak"
                     : "\(store.settings.streakWeeks) Wochen Streak")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: 0) {
            ProfileStatItem(value: "\(store.goals.count)", label: "Ziele")
            Divider().frame(height: 40)
            ProfileStatItem(value: store.totalSaved.euroFormattedCompact, label: "Gespart")
            Divider().frame(height: 40)
            ProfileStatItem(
                value: "\(store.goals.filter { $0.progress >= 1.0 }.count)",
                label: "Erreicht"
            )
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 0) {
            ProfileActionRow(icon: "gearshape.fill", title: "Einstellungen", color: .gray) {
                showSettings = true
            }
            Divider().padding(.leading, 52)
            ProfileActionRow(icon: "bell.fill", title: "Benachrichtigungen", color: AppColors.accent) {
                NotificationManager.shared.requestPermission()
            }
            Divider().padding(.leading, 52)
            ProfileActionRow(icon: "info.circle.fill", title: "App-Version 1.0.0", color: AppColors.primary) {
                // no-op
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Supporting Views

private struct ProfileStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProfileActionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
