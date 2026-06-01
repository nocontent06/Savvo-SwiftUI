import SwiftUI

/// Settings screen for name, streak overview, notification control, and app info.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: GoalsStore

    @State private var firstName: String = ""

    var body: some View {
        NavigationStack {
            Form {

                // ── Profile ───────────────────────────────────────────
                Section {
                    HStack(spacing: 14) {
                        Text("👋")
                            .font(.system(size: 28))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Wie heißt du?")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Text("Dein Name wird im Gruß auf dem Startbildschirm angezeigt.")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    TextField("Vorname", text: $firstName)
                        .font(.system(size: 16, design: .rounded))
                        .submitLabel(.done)
                } header: {
                    Text("Profil")
                }

                // ── Statistics ────────────────────────────────────────
                Section {
                    HStack {
                        Image(systemName: "flame.fill").foregroundColor(.orange)
                        Text(store.settings.streakWeeks == 1
                             ? "1 Woche Streak"
                             : "\(store.settings.streakWeeks) Wochen Streak")
                            .font(.system(size: 15, design: .rounded))
                    }
                    HStack {
                        Image(systemName: "target").foregroundColor(AppColors.primary)
                        Text("\(store.goals.count) aktive \(store.goals.count == 1 ? "Ziel" : "Ziele")")
                            .font(.system(size: 15, design: .rounded))
                    }
                    HStack {
                        Image(systemName: "eurosign.circle.fill").foregroundColor(AppColors.accent)
                        Text("Gesamt gespart: \(store.totalSaved.euroFormatted)")
                            .font(.system(size: 15, design: .rounded))
                    }
                } header: {
                    Text("Statistiken")
                }

                // ── Notifications ─────────────────────────────────────
                Section {
                    Button {
                        NotificationManager.shared.requestPermission()
                    } label: {
                        Label("Benachrichtigungen aktivieren", systemImage: "bell.fill")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(AppColors.primary)
                    }
                } header: {
                    Text("Benachrichtigungen")
                } footer: {
                    Text("Erhalte jeden Montag eine Erinnerung sowie Meilenstein-Benachrichtigungen.")
                        .font(.system(size: 12, design: .rounded))
                }

                // ── Darstellung ───────────────────────────────────────
                Section {
                    Picker("Diagrammstil", selection: $store.settings.progressChartStyle) {
                        ForEach(ProgressChartStyle.allCases, id: \.self) { style in
                            Label(style.label, systemImage: style.icon).tag(style)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: store.settings.progressChartStyle) { _ in store.saveData() }
                } header: {
                    Text("Darstellung")
                } footer: {
                    Text("Wähle, wie du deinen Sparfortschritt in der Detailansicht sehen möchtest.")
                        .font(.system(size: 12, design: .rounded))
                }

                // ── App Info ──────────────────────────────────────────
                Section {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Sprache", value: "Deutsch")
                    LabeledContent("Währung", value: "€ Euro")
                } header: {
                    Text("App-Info")
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        store.settings.firstName = firstName.trimmingCharacters(in: .whitespaces)
                        store.saveData()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primary)
                }
            }
            .onAppear {
                firstName = store.settings.firstName
            }
        }
    }
}
