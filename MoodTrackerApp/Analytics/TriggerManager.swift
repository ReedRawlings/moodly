import Foundation
import SwiftData

/// Manages proactive triggers and alerts
struct TriggerManager {
    let modelContext: ModelContext

    /// Represents a trigger that should fire
    struct PendingTrigger {
        let type: TriggerType
        let message: String
        let priority: Int

        enum TriggerType: String {
            case missedHelpfulActivity = "missed_helpful_activity"
            case lowMoodStreak = "low_mood_streak"
            case sleepWarning = "sleep_warning"
            case positiveStreak = "positive_streak"
        }
    }

    /// Check all trigger conditions and return any that should fire
    func checkAllTriggers(
        entries: [MoodEntry],
        correlations: [ActivityCorrelation],
        existingTriggers: [Trigger]
    ) -> [PendingTrigger] {
        var pendingTriggers: [PendingTrigger] = []

        // Check each trigger type
        if let trigger = checkMissedHelpfulActivity(entries: entries, correlations: correlations, existingTriggers: existingTriggers) {
            pendingTriggers.append(trigger)
        }

        if let trigger = checkLowMoodStreak(entries: entries, existingTriggers: existingTriggers) {
            pendingTriggers.append(trigger)
        }

        if let trigger = checkSleepWarning(entries: entries, existingTriggers: existingTriggers) {
            pendingTriggers.append(trigger)
        }

        if let trigger = checkPositiveStreak(entries: entries, existingTriggers: existingTriggers) {
            pendingTriggers.append(trigger)
        }

        // Sort by priority and return max 1
        return Array(pendingTriggers.sorted { $0.priority > $1.priority }.prefix(1))
    }

    /// Check if user hasn't done a high-success activity recently
    private func checkMissedHelpfulActivity(
        entries: [MoodEntry],
        correlations: [ActivityCorrelation],
        existingTriggers: [Trigger]
    ) -> PendingTrigger? {
        // Find high-success activities (>70%)
        let helpfulActivities = correlations.filter { $0.successRate > 0.7 }

        for activity in helpfulActivities {
            // Check when last done
            let entriesWithActivity = entries
                .filter { $0.activities.contains(activity.activityId) }
                .sorted { $0.date > $1.date }

            guard let lastEntry = entriesWithActivity.first else { continue }

            let daysSince = Calendar.current.dateComponents([.day], from: lastEntry.date, to: Date()).day ?? 0

            // Threshold depends on activity type
            let threshold = thresholdDays(for: activity.activityId)

            if daysSince >= threshold {
                // Check if we already fired this trigger recently
                if hasFiredRecently(type: .missedHelpfulActivity, within: 7, existingTriggers: existingTriggers) {
                    continue
                }

                let successPercent = Int(activity.successRate * 100)
                return PendingTrigger(
                    type: .missedHelpfulActivity,
                    message: "Haven't done \(activity.activityId) in \(daysSince) days. It usually helps your mood by \(successPercent)%",
                    priority: 2
                )
            }
        }

        return nil
    }

    /// Check for low mood streak
    private func checkLowMoodStreak(entries: [MoodEntry], existingTriggers: [Trigger]) -> PendingTrigger? {
        let sortedEntries = entries.sorted { $0.date > $1.date }
        guard sortedEntries.count >= 3 else { return nil }

        // Check last 3 entries
        let recentMoods = sortedEntries.prefix(3).map { $0.mood }

        if recentMoods.allSatisfy({ $0 <= 2 }) {
            // Check if already fired recently
            if hasFiredRecently(type: .lowMoodStreak, within: 7, existingTriggers: existingTriggers) {
                return nil
            }

            return PendingTrigger(
                type: .lowMoodStreak,
                message: "Rough few days. Here are 3 things that have helped you before",
                priority: 3
            )
        }

        return nil
    }

    /// Check for sleep warning
    private func checkSleepWarning(entries: [MoodEntry], existingTriggers: [Trigger]) -> PendingTrigger? {
        let recentEntries = entries
            .filter { $0.sleepHours != nil }
            .sorted { $0.date > $1.date }
            .prefix(5)

        guard recentEntries.count >= 5 else { return nil }

        let avgSleep = recentEntries.compactMap { $0.sleepHours }.reduce(0, +) / Double(recentEntries.count)

        if avgSleep < 6.0 {
            if hasFiredRecently(type: .sleepWarning, within: 7, existingTriggers: existingTriggers) {
                return nil
            }

            return PendingTrigger(
                type: .sleepWarning,
                message: "Sleep's been rough (avg \(String(format: "%.1f", avgSleep))h). This typically affects mood in 2-3 days",
                priority: 2
            )
        }

        return nil
    }

    /// Check for positive streak
    private func checkPositiveStreak(entries: [MoodEntry], existingTriggers: [Trigger]) -> PendingTrigger? {
        let sortedEntries = entries.sorted { $0.date > $1.date }
        guard sortedEntries.count >= 5 else { return nil }

        let recentMoods = sortedEntries.prefix(5).map { $0.mood }

        if recentMoods.allSatisfy({ $0 >= 4 }) {
            if hasFiredRecently(type: .positiveStreak, within: 14, existingTriggers: existingTriggers) {
                return nil
            }

            return PendingTrigger(
                type: .positiveStreak,
                message: "Great week! Keep up whatever you're doing",
                priority: 1
            )
        }

        return nil
    }

    /// Log a trigger as fired
    func logTrigger(_ pending: PendingTrigger) {
        let trigger = Trigger(
            triggerType: pending.type.rawValue,
            message: pending.message
        )
        modelContext.insert(trigger)
        try? modelContext.save()
    }

    // MARK: - Helper Methods

    private func hasFiredRecently(type: PendingTrigger.TriggerType, within days: Int, existingTriggers: [Trigger]) -> Bool {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        return existingTriggers.contains { trigger in
            trigger.triggerType == type.rawValue && trigger.firedAt >= cutoffDate
        }
    }

    private func thresholdDays(for activityId: String) -> Int {
        switch activityId {
        case "exercise": return 3
        case "social_time", "friends", "family": return 5
        default: return 4
        }
    }
}
