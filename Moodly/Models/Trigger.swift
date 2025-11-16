import Foundation
import SwiftData

/// Track which proactive alerts have been shown to prevent duplicates
@Model
final class Trigger {
    /// Unique identifier
    var id: UUID

    /// Type of trigger (e.g., "missed_exercise", "mood_streak", "sleep_warning")
    var triggerType: String

    /// When the trigger was fired
    var firedAt: Date

    /// Whether user dismissed or acted on the trigger
    var userDismissed: Bool

    /// The message shown to the user
    var message: String

    init(
        id: UUID = UUID(),
        triggerType: String,
        firedAt: Date = Date(),
        userDismissed: Bool = false,
        message: String
    ) {
        self.id = id
        self.triggerType = triggerType
        self.firedAt = firedAt
        self.userDismissed = userDismissed
        self.message = message
    }
}
