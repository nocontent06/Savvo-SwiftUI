import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
        .environmentObject(GoalsStore())
}
