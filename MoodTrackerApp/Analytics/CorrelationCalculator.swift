import Foundation
import SwiftData

/// Calculates correlations between activities and mood outcomes
struct CorrelationCalculator {
    let modelContext: ModelContext

    /// Minimum number of total entries required before calculating correlations
    private let minimumTotalEntries = 10

    /// Minimum observations of a specific activity required
    private let minimumActivityObservations = 3

    /// Calculate correlations for all tracked activities
    /// Returns array of ActivityCorrelation entities
    func calculateAllCorrelations(entries: [MoodEntry], trackedActivities: [String]) async -> [ActivityCorrelation] {
        guard entries.count >= minimumTotalEntries else {
            return []
        }

        var correlations: [ActivityCorrelation] = []

        for activityId in trackedActivities {
            if let correlation = calculateCorrelation(for: activityId, in: entries) {
                correlations.append(correlation)
            }
        }

        return correlations
    }

    /// Calculate correlation for a single activity
    private func calculateCorrelation(for activityId: String, in entries: [MoodEntry]) -> ActivityCorrelation? {
        // Filter entries with and without this activity
        let entriesWithActivity = entries.filter { $0.activities.contains(activityId) }
        let entriesWithoutActivity = entries.filter { !$0.activities.contains(activityId) }

        // Need minimum observations
        guard entriesWithActivity.count >= minimumActivityObservations else {
            return nil
        }

        // Calculate average moods
        let avgMoodWith = entriesWithActivity.map { Double($0.mood) }.reduce(0, +) / Double(entriesWithActivity.count)
        let avgMoodWithout = entriesWithoutActivity.isEmpty ? 0 : entriesWithoutActivity.map { Double($0.mood) }.reduce(0, +) / Double(entriesWithoutActivity.count)

        // Calculate success rate (% of times mood >= 4 after activity)
        let successfulEntries = entriesWithActivity.filter { $0.mood >= 4 }.count
        let successRate = Double(successfulEntries) / Double(entriesWithActivity.count)

        return ActivityCorrelation(
            activityId: activityId,
            avgMoodWith: avgMoodWith,
            avgMoodWithout: avgMoodWithout,
            successRate: successRate,
            timesObserved: entriesWithActivity.count
        )
    }

    /// Update correlations in database
    func updateCorrelations(for entries: [MoodEntry], trackedActivities: [String]) async throws {
        // Delete existing correlations
        try modelContext.delete(model: ActivityCorrelation.self)

        // Calculate new correlations
        let correlations = await calculateAllCorrelations(entries: entries, trackedActivities: trackedActivities)

        // Insert new correlations
        for correlation in correlations {
            modelContext.insert(correlation)
        }

        try modelContext.save()
    }
}
