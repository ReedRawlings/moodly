import SwiftUI
import SwiftData

/// Main navigation structure for the app
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    @State private var selectedTab = 0

    var body: some View {
        Group {
            if shouldShowOnboarding {
                // Show onboarding flow if not completed
                OnboardingContainerView()
            } else {
                // Show main tab navigation
                TabView(selection: $selectedTab) {
                    MoodEntryView()
                        .tabItem {
                            Label("Entry", systemImage: "face.smiling")
                        }
                        .tag(0)

                    CalendarView()
                        .tabItem {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag(1)

                    InsightsView()
                        .tabItem {
                            Label("Insights", systemImage: "chart.bar")
                        }
                        .tag(2)

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(3)
                }
            }
        }
    }

    /// Check if user has completed onboarding
    private var shouldShowOnboarding: Bool {
        guard let profile = userProfiles.first else {
            // No profile exists, need onboarding
            return true
        }
        return !profile.onboardingCompleted
    }
}

/// Temporary placeholder for onboarding container
struct OnboardingContainerView: View {
    var body: some View {
        WelcomeView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            MoodEntry.self,
            UserProfile.self,
            ActivityCorrelation.self,
            Trigger.self
        ], inMemory: true)
}
