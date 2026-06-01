import SwiftUI

@main
struct SavvoApp: App {
    @StateObject private var store = GoalsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
