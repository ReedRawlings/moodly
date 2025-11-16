import Foundation
import SwiftData

/// Pre-computed correlations between activities and mood to avoid re-calculating constantly
@Model
final class ActivityCorrelation {
    /// Unique identifier
    var id: UUID

    /// Reference to the activity being analyzed
    var activityId: String

    /// Average mood when doing this activity
    var avgMoodWith: Double

    /// Average mood when not doing this activity
    var avgMoodWithout: Double

    /// Percentage of times mood improved (>=4) after this activity
    var successRate: Double

    /// How many entries include this activity
    var timesObserved: Int

    /// When correlation was last calculated
    var lastCalculated: Date

    init(
        id: UUID = UUID(),
        activityId: String,
        avgMoodWith: Double,
        avgMoodWithout: Double,
        successRate: Double,
        timesObserved: Int,
        lastCalculated: Date = Date()
    ) {
        self.id = id
        self.activityId = activityId
        self.avgMoodWith = avgMoodWith
        self.avgMoodWithout = avgMoodWithout
        self.successRate = successRate
        self.timesObserved = timesObserved
        self.lastCalculated = lastCalculated
    }

    /// Correlation strength (difference between with and without)
    var correlationStrength: Double {
        avgMoodWith - avgMoodWithout
    }
}
