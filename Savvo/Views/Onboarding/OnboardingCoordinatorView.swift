import SwiftUI

struct OnboardingCoordinatorView: View {
    @EnvironmentObject var store: GoalsStore

    enum Step: Equatable {
        case welcome
        case categoryPicker
        case goalBuilder(GoalCategory)
    }

    @State private var step: Step = .welcome
    @State private var forward = true

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if step != .welcome {
                    progressBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .transition(.opacity)
                }

                currentStepView
                    .id(step)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
    }

    @ViewBuilder
    private var currentStepView: some View {
        switch step {
        case .welcome:
            OnboardingWelcomeView {
                navigateTo(.categoryPicker)
            }
        case .categoryPicker:
            OnboardingCategoryPickerView(
                onBack: { navigateBack(to: .welcome) },
                onSelect: { category in navigateTo(.goalBuilder(category)) }
            )
        case .goalBuilder(let category):
            OnboardingGoalBuilderView(
                category: category,
                onBack: { navigateBack(to: .categoryPicker) },
                onFinish: { goal in
                    store.addGoal(goal)
                    store.settings.hasCompletedOnboarding = true
                    store.saveData()
                }
            )
        }
    }

    private var progressBar: some View {
        let progress: Double = {
            if case .goalBuilder = step { return 1.0 }
            return 0.5
        }()
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(height: 4)
                RoundedRectangle(cornerRadius: 3)
                    .fill(AppColors.primary)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: 4)
    }

    private func navigateTo(_ newStep: Step) {
        forward = true
        step = newStep
    }

    private func navigateBack(to newStep: Step) {
        forward = false
        step = newStep
    }
}
