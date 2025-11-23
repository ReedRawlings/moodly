import SwiftUI
import SwiftData
import UserNotifications

/// Notification permission and time selection view
struct NotificationSetupView: View {
    @Environment(\.modelContext) private var modelContext

    let selectedGoal: String
    let selectedCategories: [String]

    @State private var notificationsEnabled = false
    @State private var selectedTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @State private var permissionStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding(.top, 32)

                Text("Daily Reminders")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Get a gentle nudge each day to check in with your mood")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Time Picker Section
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.blue)
                    Text("Reminder Time")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)

                DatePicker(
                    "Select time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 200)
                .padding(.horizontal)
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            // Benefits List
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "Track patterns more consistently")
                BenefitRow(icon: "lightbulb", text: "Get helpful insights and suggestions")
                BenefitRow(icon: "bell.slash", text: "You can change this anytime in settings")
            }
            .padding(.horizontal, 32)

            Spacer()

            // Action Buttons
            VStack(spacing: 12) {
                NavigationLink {
                    FirstEntryTutorialView(
                        selectedGoal: selectedGoal,
                        selectedCategories: selectedCategories,
                        notificationsEnabled: true,
                        preferredTime: selectedTime
                    )
                } label: {
                    Text("Enable Notifications")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    requestNotificationPermission()
                })

                NavigationLink {
                    FirstEntryTutorialView(
                        selectedGoal: selectedGoal,
                        selectedCategories: selectedCategories,
                        notificationsEnabled: false,
                        preferredTime: nil
                    )
                } label: {
                    Text("Skip for Now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .navigationTitle("Step 4 of 5")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkNotificationStatus()
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                permissionStatus = settings.authorizationStatus
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationsEnabled = granted
            }
        }
    }
}

/// Benefit row component
struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSetupView(
            selectedGoal: "reduce_stress",
            selectedCategories: ["sleep", "exercise", "meditation"]
        )
        .modelContainer(for: [UserProfile.self], inMemory: true)
    }
}
