import Foundation

/// Detects recurring patterns in mood data
struct PatternDetector {

    /// Represents a detected pattern
    struct Pattern {
        let type: PatternType
        let description: String
        let confidence: Double

        enum PatternType: String {
            case streakLowMood = "low_mood_streak"
            case streakHighMood = "high_mood_streak"
            case streakNeutral = "neutral_streak"
            case dayOfWeek = "day_of_week"
            case sleepCorrelation = "sleep_correlation"
            case activityGap = "activity_gap"
        }
    }

    /// Detect all patterns in the provided entries
    func detectPatterns(in entries: [MoodEntry]) -> [Pattern] {
        var patterns: [Pattern] = []

        // Streak detection
        if let streakPattern = detectStreaks(in: entries) {
            patterns.append(streakPattern)
        }

        // Day of week patterns
        if let dayPattern = detectDayOfWeekPatterns(in: entries) {
            patterns.append(dayPattern)
        }

        // Sleep correlation
        if let sleepPattern = detectSleepCorrelation(in: entries) {
            patterns.append(sleepPattern)
        }

        return patterns
    }

    /// Detect mood streaks (3+ days in a row)
    private func detectStreaks(in entries: [MoodEntry]) -> Pattern? {
        let sortedEntries = entries.sorted { $0.date < $1.date }
        guard sortedEntries.count >= 3 else { return nil }

        var currentStreak = 1
        var currentMoodCategory: String?

        for i in 1..<sortedEntries.count {
            let prevMood = sortedEntries[i-1].mood
            let currMood = sortedEntries[i].mood

            let prevCategory = moodCategory(for: prevMood)
            let currCategory = moodCategory(for: currMood)

            if prevCategory == currCategory {
                currentStreak += 1
                currentMoodCategory = currCategory
            } else {
                currentStreak = 1
                currentMoodCategory = currCategory
            }

            // If streak >= 3, return pattern
            if currentStreak >= 3, let category = currentMoodCategory {
                let type: Pattern.PatternType
                switch category {
                case "low": type = .streakLowMood
                case "high": type = .streakHighMood
                default: type = .streakNeutral
                }

                return Pattern(
                    type: type,
                    description: "You've felt \(category) for \(currentStreak) consecutive days",
                    confidence: min(Double(currentStreak) / 7.0, 1.0)
                )
            }
        }

        return nil
    }

    /// Detect day-of-week patterns
    private func detectDayOfWeekPatterns(in entries: [MoodEntry]) -> Pattern? {
        guard entries.count >= 14 else { return nil } // Need at least 2 weeks

        var dayAverages: [Int: [Int]] = [:]
        let calendar = Calendar.current

        // Group moods by day of week
        for entry in entries {
            let weekday = calendar.component(.weekday, from: entry.date)
            dayAverages[weekday, default: []].append(entry.mood)
        }

        // Calculate averages
        var averages: [(day: Int, avg: Double)] = []
        for (day, moods) in dayAverages {
            let avg = Double(moods.reduce(0, +)) / Double(moods.count)
            averages.append((day, avg))
        }

        // Find overall average
        let overallAvg = averages.map { $0.avg }.reduce(0, +) / Double(averages.count)

        // Find day with biggest deviation
        if let worstDay = averages.min(by: { abs($0.avg - overallAvg) < abs($1.avg - overallAvg) }),
           abs(worstDay.avg - overallAvg) >= 1.0 {
            let dayName = dayName(for: worstDay.day)
            return Pattern(
                type: .dayOfWeek,
                description: "\(dayName)s average \(String(format: "%.1f", worstDay.avg)), your overall average is \(String(format: "%.1f", overallAvg))",
                confidence: min(abs(worstDay.avg - overallAvg) / 2.0, 1.0)
            )
        }

        return nil
    }

    /// Detect sleep-mood correlation
    private func detectSleepCorrelation(in entries: [MoodEntry]) -> Pattern? {
        let entriesWithSleep = entries.filter { $0.sleepHours != nil }
        guard entriesWithSleep.count >= 10 else { return nil }

        let lowSleepEntries = entriesWithSleep.filter { ($0.sleepHours ?? 0) < 6.0 }
        let goodSleepEntries = entriesWithSleep.filter { ($0.sleepHours ?? 0) >= 7.5 }

        guard !lowSleepEntries.isEmpty, !goodSleepEntries.isEmpty else { return nil }

        let lowSleepAvg = Double(lowSleepEntries.map { $0.mood }.reduce(0, +)) / Double(lowSleepEntries.count)
        let goodSleepAvg = Double(goodSleepEntries.map { $0.mood }.reduce(0, +)) / Double(goodSleepEntries.count)

        if goodSleepAvg - lowSleepAvg >= 0.8 {
            return Pattern(
                type: .sleepCorrelation,
                description: "Mood drops when sleep < 6 hours (avg \(String(format: "%.1f", lowSleepAvg)) vs \(String(format: "%.1f", goodSleepAvg)))",
                confidence: min((goodSleepAvg - lowSleepAvg) / 2.0, 1.0)
            )
        }

        return nil
    }

    // MARK: - Helper Methods

    private func moodCategory(for mood: Int) -> String {
        switch mood {
        case 1...2: return "low"
        case 3: return "neutral"
        case 4...5: return "high"
        default: return "neutral"
        }
    }

    private func dayName(for weekday: Int) -> String {
        let days = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[weekday]
    }
}
