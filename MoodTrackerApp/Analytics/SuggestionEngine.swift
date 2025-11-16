import Foundation
import SwiftData

/// Recommends activities most likely to improve user's mood
struct SuggestionEngine {

    struct Suggestion {
        let activityId: String
        let activityName: String
        let successRate: Double
        let timesObserved: Int
        let reason: String

        var displayText: String {
            "\(activityName) helped \(Int(successRate * 100))% of the time (\(timesObserved) observations)"
        }
    }

    private let minimumSuccessRate = 0.6
    private let minimumObservations = 3

    /// Generate suggestions based on correlations
    func generateSuggestions(
        from correlations: [ActivityCorrelation],
        currentMood: Int,
        recentEntries: [MoodEntry]
    ) -> [Suggestion] {
        // If we have correlations, use them
        if !correlations.isEmpty {
            return suggestionsFromCorrelations(correlations, recentEntries: recentEntries)
        }

        // Otherwise, use fallback generic suggestions
        return fallbackSuggestions()
    }

    /// Generate suggestions from calculated correlations
    private func suggestionsFromCorrelations(
        _ correlations: [ActivityCorrelation],
        recentEntries: [MoodEntry]
    ) -> [Suggestion] {
        // Filter correlations by minimum criteria
        let validCorrelations = correlations.filter {
            $0.successRate >= minimumSuccessRate &&
            $0.timesObserved >= minimumObservations
        }

        // Sort by success rate (primary) and times observed (secondary)
        let sorted = validCorrelations.sorted { lhs, rhs in
            if lhs.successRate != rhs.successRate {
                return lhs.successRate > rhs.successRate
            }
            return lhs.timesObserved > rhs.timesObserved
        }

        // Get recent activities (last 7 days)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentActivities = Set(recentEntries
            .filter { $0.date >= sevenDaysAgo }
            .flatMap { $0.activities })

        // Filter out activities done recently (unless they're VERY successful)
        let filtered = sorted.filter { correlation in
            !recentActivities.contains(correlation.activityId) || correlation.successRate >= 0.85
        }

        // Return top 3
        return filtered.prefix(3).map { correlation in
            Suggestion(
                activityId: correlation.activityId,
                activityName: formatActivityName(correlation.activityId),
                successRate: correlation.successRate,
                timesObserved: correlation.timesObserved,
                reason: "Based on your history"
            )
        }
    }

    /// Fallback suggestions when insufficient data
    private func fallbackSuggestions() -> [Suggestion] {
        let fallbacks = [
            ("walk", "Take a 10-minute walk outside", "Research-backed"),
            ("social", "Call or text a friend", "Research-backed"),
            ("breathing", "Try 5 minutes of deep breathing", "Research-backed")
        ]

        return fallbacks.map { (id, name, reason) in
            Suggestion(
                activityId: id,
                activityName: name,
                successRate: 0.75, // Generic estimate
                timesObserved: 0,
                reason: reason
            )
        }
    }

    /// Check if suggestion is feasible based on time of day
    func isFeasible(activityId: String, at date: Date = Date()) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)

        // Don't suggest exercise late at night
        if activityId == "exercise" && hour >= 22 {
            return false
        }

        // Don't suggest caffeine late in the day
        if activityId == "caffeine" && hour >= 16 {
            return false
        }

        return true
    }

    // MARK: - Helper Methods

    private func formatActivityName(_ activityId: String) -> String {
        activityId
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
