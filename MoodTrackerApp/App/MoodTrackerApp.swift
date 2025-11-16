import SwiftUI
import SwiftData

@main
struct MoodTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            MoodEntry.self,
            UserProfile.self,
            ActivityCorrelation.self,
            Trigger.self
        ])
    }
}
