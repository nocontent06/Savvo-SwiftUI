import SwiftUI

/// Form screen for adding a new goal or editing an existing one.
struct AddEditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: GoalsStore

    var existingGoal: SavingsGoal? = nil

    // ── Form state ───────────────────────────────────────────────────
    @State private var name: String = ""
    @State private var emoji: String = "🎯"
    @State private var targetAmountText: String = ""
    @State private var startingAmountText: String = ""
    @State private var months: Double = 12
    @State private var reminderEnabled: Bool = true
    @State private var reminderWeekday: Int = 2
    @State private var reminderHour: Int = 10
    @State private var reminderMinute: Int = 0
    @State private var showEmojiPicker = false

    // MARK: - Computed

    private var targetDate: Date {
        Calendar.current.date(byAdding: .month, value: Int(months), to: Date()) ?? Date()
    }

    private var targetAmount: Double { targetAmountText.asDouble ?? 0 }
    private var startingAmount: Double { startingAmountText.asDouble ?? 0 }

    private var monthlyAmount: Double {
        let remaining = max(targetAmount - startingAmount, 0)
        let m = Int(months)
        guard m > 0 else { return remaining }
        return remaining / Double(m)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && targetAmount > 0
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                var c = DateComponents()
                c.hour = reminderHour
                c.minute = reminderMinute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = c.hour ?? 10
                reminderMinute = c.minute ?? 0
            }
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    // ── Emoji selector ────────────────────────────────
                    emojiSelector

                    // ── Emoji picker grid ─────────────────────────────
                    if showEmojiPicker {
                        EmojiPickerView(selectedEmoji: $emoji)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // ── Form fields ───────────────────────────────────
                    VStack(spacing: 16) {
                        nameField
                        targetAmountField
                        startingAmountField
                        timelineSlider

                        // Live monthly calculation
                        if targetAmount > 0 {
                            monthlyCalculationCard
                        }

                        reminderSection
                    }
                    .padding(.horizontal)

                    // ── Save ──────────────────────────────────────────
                    saveButton
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(existingGoal == nil ? "Neues Ziel" : "Ziel bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(AppColors.primary)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showEmojiPicker)
            .onAppear { populateForEditing() }
        }
    }

    // MARK: - Field Views

    private var emojiSelector: some View {
        Button {
            withAnimation { showEmojiPicker.toggle() }
        } label: {
            Text(emoji)
                .font(.system(size: 66))
                .frame(width: 104, height: 104)
                .background(AppColors.primary.opacity(0.08))
                .cornerRadius(26)
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(AppColors.primary.opacity(0.25), lineWidth: 1.5)
                )
        }
        .accessibilityLabel("Emoji auswählen, aktuell: \(emoji)")
    }

    private var nameField: some View {
        formField(
            label: "Zielname",
            icon: "tag.fill"
        ) {
            TextField("z. B. Urlaub in Japan", text: $name)
                .font(.system(size: 16, design: .rounded))
        }
    }

    private var targetAmountField: some View {
        formField(
            label: "Zielbetrag (€)",
            icon: "eurosign.circle.fill"
        ) {
            TextField("z. B. 2500", text: $targetAmountText)
                .keyboardType(.decimalPad)
                .font(.system(size: 16, design: .rounded))
        }
    }

    private var startingAmountField: some View {
        formField(
            label: "Startbetrag – optional",
            icon: "arrow.right.circle.fill"
        ) {
            TextField("z. B. 500 (bereits gespart)", text: $startingAmountText)
                .keyboardType(.decimalPad)
                .font(.system(size: 16, design: .rounded))
        }
    }

    private var timelineSlider: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Laufzeit", systemImage: "calendar.badge.clock")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(months)) Monate")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primary)
            }
            Slider(value: $months, in: 1...120, step: 1)
                .tint(AppColors.primary)
            HStack {
                Text("1 Monat")
                Spacer()
                Text("10 Jahre")
            }
            .font(.system(size: 11, design: .rounded))
            .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private var monthlyCalculationCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Benötigt pro Monat")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                Text(monthlyAmount.euroFormatted)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primary)
            }
            Spacer()
            Text("📅")
                .font(.system(size: 34))
        }
        .padding(16)
        .background(AppColors.primary.opacity(0.08))
        .cornerRadius(16)
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $reminderEnabled) {
                Label("Wöchentliche Erinnerung", systemImage: "bell.fill")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .tint(AppColors.primary)

            if reminderEnabled {
                HStack {
                    Text("Erinnerungstag:")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("Wochentag", selection: $reminderWeekday) {
                        Text("Montag").tag(2)
                        Text("Dienstag").tag(3)
                        Text("Mittwoch").tag(4)
                        Text("Donnerstag").tag(5)
                        Text("Freitag").tag(6)
                        Text("Samstag").tag(7)
                        Text("Sonntag").tag(1)
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.primary)
                }

                HStack {
                    Text("Uhrzeit:")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    DatePicker("", selection: reminderTimeBinding, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: reminderEnabled)
    }

    private var saveButton: some View {
        Button { saveGoal() } label: {
            Text(existingGoal == nil ? "Ziel erstellen" : "Änderungen speichern")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isValid ? AppColors.primary : Color(.systemGray4))
                .cornerRadius(18)
                .shadow(
                    color: isValid ? AppColors.primary.opacity(0.35) : .clear,
                    radius: 10, x: 0, y: 5
                )
        }
        .disabled(!isValid)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formField<Content: View>(
        label: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            content()
                .padding(14)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
    }

    private func populateForEditing() {
        guard let goal = existingGoal else { return }
        name = goal.name
        emoji = goal.emoji
        targetAmountText = String(goal.targetAmount)
        startingAmountText = goal.startingAmount > 0 ? String(goal.startingAmount) : ""
        reminderEnabled = goal.reminderEnabled
        reminderWeekday = goal.reminderWeekday
        reminderHour = goal.reminderHour
        reminderMinute = goal.reminderMinute
        let m = Calendar.current
            .dateComponents([.month], from: Date(), to: goal.targetDate)
            .month ?? 12
        months = Double(max(m, 1))
    }

    private func saveGoal() {
        guard isValid else { return }

        if var existing = existingGoal {
            existing.name = name
            existing.emoji = emoji
            existing.targetAmount = targetAmount
            existing.startingAmount = startingAmount
            existing.targetDate = targetDate
            existing.reminderEnabled = reminderEnabled
            existing.reminderWeekday = reminderWeekday
            existing.reminderHour = reminderHour
            existing.reminderMinute = reminderMinute
            store.updateGoal(existing)
        } else {
            let goal = SavingsGoal(
                name: name,
                emoji: emoji,
                targetAmount: targetAmount,
                startingAmount: startingAmount,
                targetDate: targetDate,
                reminderEnabled: reminderEnabled,
                reminderWeekday: reminderWeekday,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute
            )
            store.addGoal(goal)
        }
        dismiss()
    }
}
