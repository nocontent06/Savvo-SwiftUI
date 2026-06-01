import SwiftUI

struct OnboardingCategoryPickerView: View {
    let onBack: () -> Void
    let onSelect: (GoalCategory) -> Void

    @State private var selected: GoalCategory? = nil

    let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Wofür möchtest du\nsparen?")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)

                Text("Wähle eine Kategorie – wir führen dich Schritt für Schritt durch.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .padding(.bottom, 24)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(GoalCategory.allCases) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selected == category
                        ) {
                            selected = category
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                onSelect(category)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            // Back button
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Zurück")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                }
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
        }
    }
}

private struct CategoryCard: View {
    let category: GoalCategory
    let isSelected: Bool
    let onTap: () -> Void

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scale = 0.92 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scale = 1.0 }
                onTap()
            }
        } label: {
            VStack(spacing: 12) {
                Text(category.emoji)
                    .font(.system(size: 44))
                    .frame(width: 68, height: 68)
                    .background(category.color.opacity(0.15))
                    .clipShape(Circle())

                VStack(spacing: 3) {
                    Text(category.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(category.description)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                    ? category.color.opacity(0.18)
                    : Color(.systemBackground)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .scaleEffect(scale)
        .buttonStyle(.plain)
    }
}
