import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: GoalsStore
    @State private var showOnboarding = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }

            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(AppColors.primary)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingCoordinatorView()
                .environmentObject(store)
        }
        .onAppear {
            if !store.settings.hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .onChange(of: store.settings.hasCompletedOnboarding) { completed in
            if completed { showOnboarding = false }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GoalsStore())
}
