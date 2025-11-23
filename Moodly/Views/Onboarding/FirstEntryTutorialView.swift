import SwiftUI
import SwiftData

/// Slide-based tutorial shown after onboarding, before first entry
struct FirstEntryTutorialView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let selectedGoal: String
    let selectedCategories: [String]
    let notificationsEnabled: Bool
    let preferredTime: Date?

    @State private var currentSlide = 0
    @State private var onboardingComplete = false

    private let slides: [(icon: String, title: String, description: String)] = [
        (
            "face.smiling",
            "Track Your Mood",
            "Quick daily check-ins help you understand patterns in how you feel"
        ),
        (
            "chart.xyaxis.line",
            "Discover What Helps",
            "We'll show you which activities improve your mood based on your data"
        ),
        (
            "lightbulb.fill",
            "Get Personalized Tips",
            "Receive suggestions tailored to your patterns and what works for you"
        ),
        (
            "checkmark.circle.fill",
            "You're All Set!",
            "Let's log your first mood entry and start building insights"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Slide content
            TabView(selection: $currentSlide) {
                ForEach(0..<slides.count, id: \.self) { index in
                    TutorialSlide(
                        icon: slides[index].icon,
                        title: slides[index].title,
                        description: slides[index].description,
                        isLastSlide: index == slides.count - 1
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Navigation Buttons
            VStack(spacing: 12) {
                if currentSlide == slides.count - 1 {
                    // Finish button on last slide
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Start Tracking")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    // Next button
                    Button {
                        withAnimation {
                            currentSlide += 1
                        }
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Skip button (not on last slide)
                if currentSlide < slides.count - 1 {
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip Tutorial")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .navigationTitle("Step 5 of 5")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func completeOnboarding() {
        // Create user profile with all onboarding data
        let profile = UserProfile(
            goals: [selectedGoal],
            trackingCategories: selectedCategories,
            onboardingCompleted: true,
            notificationsEnabled: notificationsEnabled,
            preferredNotificationTime: preferredTime
        )
        modelContext.insert(profile)

        // Save context
        try? modelContext.save()

        // Schedule notifications if enabled
        if notificationsEnabled, let time = preferredTime {
            scheduleNotifications(at: time)
        }

        // Mark as complete and dismiss all onboarding
        onboardingComplete = true

        // Dismiss the entire navigation stack to return to main app
        dismiss()
    }

    private func scheduleNotifications(at time: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Use NotificationManager to schedule daily reminder
        // This would call NotificationManager.scheduleDailyReminder(at: components)
        // For now, we'll add a TODO comment as NotificationManager needs to be updated
        // TODO: Call NotificationManager.scheduleDailyReminder(at: components)
    }
}

/// Single tutorial slide
struct TutorialSlide: View {
    let icon: String
    let title: String
    let description: String
    let isLastSlide: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(isLastSlide ? .green : .blue)
                .padding(.top, 32)

            // Title
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Description
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        FirstEntryTutorialView(
            selectedGoal: "reduce_stress",
            selectedCategories: ["sleep", "exercise", "meditation"],
            notificationsEnabled: true,
            preferredTime: Date()
        )
        .modelContainer(for: [UserProfile.self], inMemory: true)
    }
}
