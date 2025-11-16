import Foundation

/// Generates contextual journal prompts based on user state
struct PromptGenerator {

    /// Generate a context-aware prompt
    func generatePrompt(
        currentMood: Int,
        selectedActivities: [String],
        recentEntries: [MoodEntry]
    ) -> String {
        // Rule 1: Mood drop
        if let prompt = promptForMoodDrop(currentMood: currentMood, recentEntries: recentEntries, activities: selectedActivities) {
            return prompt
        }

        // Rule 2: Mood improvement
        if let prompt = promptForMoodImprovement(currentMood: currentMood, recentEntries: recentEntries, activities: selectedActivities) {
            return prompt
        }

        // Rule 3: Pattern continuation (same mood 3+ days)
        if let prompt = promptForPatternContinuation(currentMood: currentMood, recentEntries: recentEntries) {
            return prompt
        }

        // Rule 4: Activity-specific
        if let prompt = promptForSpecificActivity(activities: selectedActivities) {
            return prompt
        }

        // Default prompts
        return defaultPrompts.randomElement() ?? "What's on your mind right now?"
    }

    // MARK: - Prompt Rules

    /// Check for mood drop
    private func promptForMoodDrop(currentMood: Int, recentEntries: [MoodEntry], activities: [String]) -> String? {
        let recentAvg = calculateRecentAverage(entries: recentEntries, days: 7)

        if Double(currentMood) < (recentAvg - 1.0) {
            // Activity-specific prompts
            if activities.contains("work") || activities.contains("work_hours") {
                return "What about work felt especially hard today?"
            }

            if activities.contains("social_time") || activities.contains("friends") {
                return "How did social time feel different than usual?"
            }

            return "Something shifted today. What changed?"
        }

        return nil
    }

    /// Check for mood improvement
    private func promptForMoodImprovement(currentMood: Int, recentEntries: [MoodEntry], activities: [String]) -> String? {
        let recentAvg = calculateRecentAverage(entries: recentEntries, days: 7)

        if Double(currentMood) > (recentAvg + 1.0) {
            // Check for new activities
            let recentActivities = Set(recentEntries.flatMap { $0.activities })
            let newActivities = activities.filter { !recentActivities.contains($0) }

            if let newActivity = newActivities.first {
                return "First time trying \(formatActivityName(newActivity)) - how was it?"
            }

            return "You seem brighter! What helped today?"
        }

        return nil
    }

    /// Check for pattern continuation
    private func promptForPatternContinuation(currentMood: Int, recentEntries: [MoodEntry]) -> String? {
        let sortedEntries = recentEntries.sorted { $0.date > $1.date }.prefix(3)

        guard sortedEntries.count >= 3 else { return nil }

        let moods = sortedEntries.map { $0.mood }

        // Check if all similar mood
        if moods.allSatisfy({ abs($0 - currentMood) <= 1 }) {
            let moodLabel = moodLabel(for: currentMood)
            return "You've felt \(moodLabel) for a few days. What's been on your mind?"
        }

        return nil
    }

    /// Activity-specific prompts
    private func promptForSpecificActivity(activities: [String]) -> String? {
        // Check for specific activities
        if activities.contains("exercise") {
            return activityPrompts["exercise"]?.randomElement()
        }

        if activities.contains("work") || activities.contains("work_hours") {
            return activityPrompts["work"]?.randomElement()
        }

        if activities.contains("social_time") || activities.contains("friends") {
            return activityPrompts["social"]?.randomElement()
        }

        return nil
    }

    // MARK: - Helper Methods

    private func calculateRecentAverage(entries: [MoodEntry], days: Int) -> Double {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recentEntries = entries.filter { $0.date >= cutoffDate }

        guard !recentEntries.isEmpty else { return 3.0 }

        return Double(recentEntries.map { $0.mood }.reduce(0, +)) / Double(recentEntries.count)
    }

    private func formatActivityName(_ activity: String) -> String {
        activity.replacingOccurrences(of: "_", with: " ").lowercased()
    }

    private func moodLabel(for mood: Int) -> String {
        switch mood {
        case 1: return "terrible"
        case 2: return "down"
        case 3: return "okay"
        case 4: return "good"
        case 5: return "great"
        default: return "neutral"
        }
    }

    // MARK: - Prompt Templates

    private let defaultPrompts = [
        "What's the main thing affecting how you feel?",
        "What's on your mind right now?",
        "How are you really doing today?",
        "What's one thing you're grateful for today?",
        "What would make tomorrow better?"
    ]

    private let activityPrompts: [String: [String]] = [
        "exercise": [
            "How did the workout feel?",
            "Did exercise help or drain you today?",
            "How's your body feeling after that?"
        ],
        "work": [
            "What about work felt especially challenging?",
            "Work today - what stood out?",
            "How was the work situation today?"
        ],
        "social": [
            "How did social time feel today?",
            "What was it like connecting with people?",
            "Did social time energize or drain you?"
        ]
    ]
}
