import SwiftUI

struct OnboardingGoalBuilderView: View {
    let category: GoalCategory
    let onBack: () -> Void
    let onFinish: (SavingsGoal) -> Void

    @State private var goalName: String
    @State private var selectedBrand: CarBrand? = nil
    @State private var selectedModel: String = ""
    @State private var customModelName: String = ""
    @State private var selectedCountry: VacationCountry? = nil
    @State private var cityName: String = ""
    @State private var targetAmountText: String = ""
    @State private var targetDate: Date = Calendar.current.date(byAdding: .month, value: 12, to: Date()) ?? Date()
    @State private var forward = true

    enum InternalStep: Equatable {
        case carBrand, carModel, vacationCountry, vacationCity, genericName, price, date, plan
    }

    @State private var internalStep: InternalStep

    init(category: GoalCategory, onBack: @escaping () -> Void, onFinish: @escaping (SavingsGoal) -> Void) {
        self.category = category
        self.onBack = onBack
        self.onFinish = onFinish

        let initialStep: InternalStep
        let initialName: String
        switch category {
        case .auto:
            initialStep = .carBrand
            initialName = ""
        case .urlaub:
            initialStep = .vacationCountry
            initialName = ""
        default:
            initialStep = .genericName
            initialName = category.defaultName
        }
        self._internalStep = State(initialValue: initialStep)
        self._goalName = State(initialValue: initialName)
    }

    // MARK: - Computed

    private var targetAmount: Double {
        targetAmountText.asDouble ?? 0
    }

    private var months: Int {
        max(Calendar.current.dateComponents([.month], from: Date(), to: targetDate).month ?? 1, 1)
    }

    private var monthlyAmount: Double {
        guard months > 0, targetAmount > 0 else { return 0 }
        return targetAmount / Double(months)
    }

    private var goalEmoji: String {
        switch category {
        case .auto: return selectedBrand?.emoji ?? "🚗"
        case .urlaub: return selectedCountry?.flag ?? "✈️"
        default: return category.emoji
        }
    }

    private var totalSteps: Int {
        switch category {
        case .auto: return 5
        case .urlaub: return 5
        default: return 4
        }
    }

    private var currentStepNumber: Int {
        switch category {
        case .auto:
            switch internalStep {
            case .carBrand: return 1
            case .carModel: return 2
            case .price: return 3
            case .date: return 4
            case .plan: return 5
            default: return 1
            }
        case .urlaub:
            switch internalStep {
            case .vacationCountry: return 1
            case .vacationCity: return 2
            case .price: return 3
            case .date: return 4
            case .plan: return 5
            default: return 1
            }
        default:
            switch internalStep {
            case .genericName: return 1
            case .price: return 2
            case .date: return 3
            case .plan: return 4
            default: return 1
            }
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            if internalStep != .plan {
                stepIndicatorBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
            }

            stepContent
                .id(internalStep)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)
                    )
                )
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: internalStep)
    }

    private var stepIndicatorBar: some View {
        HStack {
            Text("Schritt \(currentStepNumber) von \(totalSteps)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            Spacer()
            Text(category.emoji + " " + category.displayName)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch internalStep {
        case .carBrand:
            carBrandStep
        case .carModel:
            carModelStep
        case .vacationCountry:
            vacationCountryStep
        case .vacationCity:
            vacationCityStep
        case .genericName:
            genericNameStep
        case .price:
            priceStep
        case .date:
            dateStep
        case .plan:
            OnboardingSavingsPlanPreview(
                goalName: goalName,
                emoji: goalEmoji,
                targetAmount: targetAmount,
                targetDate: targetDate,
                onFinish: onFinish,
                onBack: { navigateBack() }
            )
        }
    }

    // MARK: - Car Brand Step

    private var carBrandStep: some View {
        VStack(spacing: 0) {
            stepHeader(title: "Welche Marke?", subtitle: "Wähle deine Traummarke aus")

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                    spacing: 10
                ) {
                    ForEach(carBrands) { brand in
                        BrandCard(brand: brand, isSelected: selectedBrand?.id == brand.id) {
                            selectedBrand = brand
                            navigateTo(.carModel)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            backButtonView { onBack() }
                .padding(.bottom, 20)
        }
    }

    // MARK: - Car Model Step

    private var carModelStep: some View {
        VStack(spacing: 0) {
            stepHeader(
                title: "Welches Modell?",
                subtitle: selectedBrand?.name ?? ""
            )

            if let brand = selectedBrand, !brand.models.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(brand.models, id: \.self) { model in
                            Button {
                                selectedModel = model
                                goalName = "\(brand.name) \(model)"
                                navigateTo(.price)
                            } label: {
                                HStack {
                                    Text(brand.emoji)
                                        .font(.system(size: 20))
                                    Text(model)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedModel == model {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.primary)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 13))
                                    }
                                }
                                .padding(14)
                                .background(
                                    selectedModel == model
                                        ? AppColors.primary.opacity(0.08)
                                        : Color(.systemBackground)
                                )
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            } else {
                VStack(spacing: 20) {
                    TextField("Modellbezeichnung", text: $customModelName)
                        .font(.system(size: 18, design: .rounded))
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 20)

                    primaryButtonView(
                        title: "Weiter",
                        disabled: customModelName.trimmingCharacters(in: .whitespaces).isEmpty
                    ) {
                        let trimmed = customModelName.trimmingCharacters(in: .whitespaces)
                        selectedModel = trimmed
                        if let brand = selectedBrand {
                            goalName = "\(brand.name) \(trimmed)"
                        } else {
                            goalName = trimmed.isEmpty ? "Mein neues Auto" : trimmed
                        }
                        navigateTo(.price)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)

                Spacer()
            }

            backButtonView { navigateBack() }
                .padding(.bottom, 20)
        }
    }

    // MARK: - Vacation Country Step

    private var vacationCountryStep: some View {
        VStack(spacing: 0) {
            stepHeader(title: "Wohin soll die Reise gehen?", subtitle: "Wähle dein Traumziel")

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                    spacing: 10
                ) {
                    ForEach(vacationCountries) { country in
                        CountryCard(
                            country: country,
                            isSelected: selectedCountry?.id == country.id
                        ) {
                            selectedCountry = country
                            navigateTo(.vacationCity)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            backButtonView { onBack() }
                .padding(.bottom, 20)
        }
    }

    // MARK: - Vacation City Step

    private var vacationCityStep: some View {
        VStack(spacing: 24) {
            stepHeader(title: "Wohin genau?", subtitle: "Optional: Stadt oder Region angeben")

            VStack(alignment: .leading, spacing: 8) {
                Text("Stadt / Region (optional)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)

                TextField("z.B. Barcelona, Mallorca…", text: $cityName)
                    .font(.system(size: 18, design: .rounded))
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                primaryButtonView(title: "Weiter", disabled: false) {
                    setVacationGoalName()
                    navigateTo(.price)
                }
                .padding(.horizontal, 20)

                Button {
                    cityName = ""
                    setVacationGoalName()
                    navigateTo(.price)
                } label: {
                    Text("Überspringen")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            backButtonView { navigateBack() }
                .padding(.bottom, 20)
        }
    }

    private func setVacationGoalName() {
        let country = selectedCountry?.name ?? "Urlaub"
        let city = cityName.trimmingCharacters(in: .whitespaces)
        goalName = city.isEmpty ? country : "\(country) – \(city)"
    }

    // MARK: - Generic Name Step

    private var genericNameStep: some View {
        VStack(spacing: 24) {
            stepHeader(title: "Wie heißt dein Ziel?", subtitle: "Gib deinem Sparziel einen Namen")

            VStack(alignment: .leading, spacing: 8) {
                Text("Zielname")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)

                HStack(spacing: 12) {
                    Text(category.emoji)
                        .font(.system(size: 22))
                    TextField(category.defaultName, text: $goalName)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 20)

            primaryButtonView(
                title: "Weiter",
                disabled: goalName.trimmingCharacters(in: .whitespaces).isEmpty
            ) {
                navigateTo(.price)
            }
            .padding(.horizontal, 20)

            Spacer()

            backButtonView { onBack() }
                .padding(.bottom, 20)
        }
    }

    // MARK: - Price Step

    private var priceStep: some View {
        VStack(spacing: 24) {
            stepHeader(title: "Wie viel kostet es?", subtitle: "Gib dein Sparziel ein")

            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 8) {
                    Text("€")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(targetAmount > 0 ? AppColors.primary : .secondary)
                    TextField("0", text: $targetAmountText)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(targetAmount > 0 ? .primary : .secondary)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                .padding(.horizontal, 20)

                if targetAmount > 0 {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .foregroundColor(AppColors.accent)
                        Text("≈ \(monthlyAmount.euroFormatted) pro Monat")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .padding(14)
                    .background(AppColors.accent.opacity(0.1))
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .animation(.spring(response: 0.3), value: targetAmount > 0)

            primaryButtonView(title: "Weiter", disabled: targetAmount <= 0) {
                navigateTo(.date)
            }
            .padding(.horizontal, 20)

            Spacer()

            backButtonView { navigateBack() }
                .padding(.bottom, 20)
        }
    }

    // MARK: - Date Step

    private var dateStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                stepHeader(title: "Bis wann?", subtitle: "Wann möchtest du dein Ziel erreichen?")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Schnellauswahl")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    HStack(spacing: 8) {
                        ForEach(
                            [("+6 Mo", 6), ("+1 Jahr", 12), ("+2 Jahre", 24), ("+5 Jahre", 60)],
                            id: \.0
                        ) { label, monthCount in
                            Button {
                                targetDate = Calendar.current.date(
                                    byAdding: .month, value: monthCount, to: Date()
                                ) ?? Date()
                            } label: {
                                Text(label)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppColors.primary.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)

                DatePicker(
                    "Zieldatum",
                    selection: $targetDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .accentColor(AppColors.primary)
                .padding(.horizontal, 16)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 20)

                primaryButtonView(title: "Weiter", disabled: false) {
                    navigateTo(.plan)
                }
                .padding(.horizontal, 20)

                backButtonView { navigateBack() }
                    .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Navigation

    private func navigateTo(_ newStep: InternalStep) {
        forward = true
        internalStep = newStep
    }

    private func navigateBack() {
        forward = false
        let nextStep: InternalStep?
        switch internalStep {
        case .plan:
            nextStep = .date
        case .date:
            nextStep = .price
        case .price:
            switch category {
            case .auto: nextStep = .carModel
            case .urlaub: nextStep = .vacationCity
            default: nextStep = .genericName
            }
        case .carModel:
            nextStep = .carBrand
        case .carBrand:
            nextStep = nil
        case .vacationCity:
            nextStep = .vacationCountry
        case .vacationCountry:
            nextStep = nil
        case .genericName:
            nextStep = nil
        }

        if let next = nextStep {
            internalStep = next
        } else {
            onBack()
        }
    }

    // MARK: - Reusable UI

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func primaryButtonView(title: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 19))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(disabled ? Color(.systemGray4) : AppColors.primary)
            .cornerRadius(18)
            .shadow(color: disabled ? .clear : AppColors.primary.opacity(0.35), radius: 10, x: 0, y: 5)
        }
        .disabled(disabled)
    }

    private func backButtonView(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                Text("Zurück")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
            }
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Brand Card

private struct BrandCard: View {
    let brand: CarBrand
    let isSelected: Bool
    let onTap: () -> Void

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scale = 0.9 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scale = 1.0 }
                onTap()
            }
        } label: {
            VStack(spacing: 6) {
                Text(brand.emoji)
                    .font(.system(size: 26))
                    .frame(width: 50, height: 50)
                    .background(brand.color.opacity(0.15))
                    .clipShape(Circle())
                Text(brand.name)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(isSelected ? brand.color.opacity(0.18) : Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? brand.color : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .scaleEffect(scale)
        .buttonStyle(.plain)
    }
}

// MARK: - Country Card

private struct CountryCard: View {
    let country: VacationCountry
    let isSelected: Bool
    let onTap: () -> Void

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scale = 0.9 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scale = 1.0 }
                onTap()
            }
        } label: {
            VStack(spacing: 4) {
                Text(country.flag)
                    .font(.system(size: 30))
                Text(country.name)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(isSelected ? AppColors.primary.opacity(0.12) : Color(.systemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(scale)
        .buttonStyle(.plain)
    }
}
