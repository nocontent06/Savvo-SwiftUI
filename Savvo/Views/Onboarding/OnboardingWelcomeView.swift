import SwiftUI

struct OnboardingWelcomeView: View {
    @EnvironmentObject var store: GoalsStore
    let onNext: () -> Void

    @State private var name = ""
    @FocusState private var nameFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero
                VStack(spacing: 16) {
                    Text("💰")
                        .font(.system(size: 80))
                        .padding(.top, 48)

                    Text("Savvo")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundColor(AppColors.primary)

                    Text("Dein persönlicher\nSpar-Assistent")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)

                    Text("Spare gezielt auf deine Träume hin –\nmit einem smarten Plan.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                // Feature pills
                HStack(spacing: 10) {
                    FeaturePill(icon: "🎯", label: "Sparziele")
                    FeaturePill(icon: "📊", label: "Fortschritt")
                    FeaturePill(icon: "🔔", label: "Erinnerungen")
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)

                // Name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wie heißt du?")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    HStack(spacing: 12) {
                        Text("👋")
                            .font(.system(size: 22))
                        TextField("Dein Vorname", text: $name)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .focused($nameFocused)
                            .submitLabel(.continue)
                            .onSubmit {
                                if !name.trimmingCharacters(in: .whitespaces).isEmpty { saveAndNext() }
                            }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(nameFocused ? AppColors.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
                    )
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)

                // CTA button
                Button(action: saveAndNext) {
                    HStack(spacing: 10) {
                        Text("Los geht's")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color(.systemGray4)
                            : AppColors.primary
                    )
                    .cornerRadius(20)
                    .shadow(
                        color: name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? .clear : AppColors.primary.opacity(0.4),
                        radius: 12, x: 0, y: 6
                    )
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.top, 24)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { nameFocused = true }
        }
    }

    private func saveAndNext() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.settings.firstName = trimmed
        store.saveData()
        onNext()
    }
}

private struct FeaturePill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Text(icon).font(.system(size: 14))
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
