import SwiftUI
import SwiftData

/// App settings and preferences
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    @State private var notificationsEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    Toggle("Daily reminders", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            updateNotificationPreference(newValue)
                        }
                }

                Section("Data") {
                    Button("Export Data") {
                        // TODO: Implement data export
                    }

                    Button("Reset Onboarding", role: .destructive) {
                        resetOnboarding()
                    }
                }

                Section("Tracking") {
                    if let profile = userProfiles.first {
                        NavigationLink("Edit Categories") {
                            Text("Category editor coming soon")
                        }

                        Text("Currently tracking: \(profile.trackingCategories.count) categories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadSettings()
            }
        }
    }

    private func loadSettings() {
        if let profile = userProfiles.first {
            notificationsEnabled = profile.notificationsEnabled
        }
    }

    private func updateNotificationPreference(_ enabled: Bool) {
        guard let profile = userProfiles.first else { return }
        profile.notificationsEnabled = enabled
        try? modelContext.save()
    }

    private func resetOnboarding() {
        guard let profile = userProfiles.first else { return }
        profile.onboardingCompleted = false
        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
