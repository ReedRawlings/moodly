import Foundation
import SwiftData

/// Stores each mood check-in with associated activities and optional journal/sleep data
@Model
final class MoodEntry {
    /// Unique identifier
    var id: UUID

    /// When the mood was logged
    var date: Date

    /// Mood rating on 1-5 scale: 1=terrible, 2=bad, 3=okay, 4=good, 5=great
    var mood: Int

    /// Array of activity identifiers that occurred this day
    var activities: [String]

    /// Optional written reflection/journal entry
    var journalText: String?

    /// Optional hours of sleep
    var sleepHours: Double?

    /// Optional energy level on 1-5 scale
    var energyLevel: Int?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: Int,
        activities: [String] = [],
        journalText: String? = nil,
        sleepHours: Double? = nil,
        energyLevel: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.activities = activities
        self.journalText = journalText
        self.sleepHours = sleepHours
        self.energyLevel = energyLevel
    }
}
