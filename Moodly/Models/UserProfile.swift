import Foundation
import SwiftData

/// Stores user preferences and settings
@Model
final class UserProfile {
    /// Unique identifier
    var id: UUID

    /// User's selected goals (e.g., "reduce_stress", "better_sleep")
    var goals: [String]

    /// Activities user chose to track
    var trackingCategories: [String]

    /// Whether user has completed onboarding flow
    var onboardingCompleted: Bool

    /// When the profile was created
    var createdAt: Date

    /// Whether user has enabled notifications
    var notificationsEnabled: Bool

    /// Preferred time for daily notification reminders
    var preferredNotificationTime: Date?

    init(
        id: UUID = UUID(),
        goals: [String] = [],
        trackingCategories: [String] = [],
        onboardingCompleted: Bool = false,
        createdAt: Date = Date(),
        notificationsEnabled: Bool = false,
        preferredNotificationTime: Date? = nil
    ) {
        self.id = id
        self.goals = goals
        self.trackingCategories = trackingCategories
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
        self.notificationsEnabled = notificationsEnabled
        self.preferredNotificationTime = preferredNotificationTime
    }
}
