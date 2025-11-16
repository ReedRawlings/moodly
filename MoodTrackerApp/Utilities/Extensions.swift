import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is in current week
    var isInCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// End of day
    var endOfDay: Date {
        let startOfDay = self.startOfDay
        return Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }

    /// Format as relative string (e.g., "Today", "Yesterday", "2 days ago")
    var relativeFormatted: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if let days = calendar.dateComponents([.day], from: self, to: now).day, days < 7 {
            return "\(days) days ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }
}

// MARK: - Array Extensions

extension Array where Element == MoodEntry {
    /// Get entries from last N days
    func last(_ days: Int) -> [MoodEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return self.filter { $0.date >= cutoffDate }
    }

    /// Calculate average mood
    var averageMood: Double {
        guard !isEmpty else { return 0 }
        return Double(self.map { $0.mood }.reduce(0, +)) / Double(count)
    }

    /// Get current streak of consecutive days
    func currentStreak() -> Int {
        let sortedEntries = self.sorted { $0.date > $1.date }
        guard !sortedEntries.isEmpty else { return 0 }

        var streak = 1
        let calendar = Calendar.current

        for i in 0..<(sortedEntries.count - 1) {
            let currentDate = sortedEntries[i].date
            let nextDate = sortedEntries[i + 1].date

            let dayDiff = calendar.dateComponents([.day], from: nextDate.startOfDay, to: currentDate.startOfDay).day ?? 0

            if dayDiff == 1 {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }
}

// MARK: - Int Extensions

extension Int {
    /// Convert mood value to emoji
    var moodEmoji: String {
        switch self {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }

    /// Convert mood value to color
    var moodColor: Color {
        switch self {
        case 1: return Color(hex: "9B7EBD")
        case 2: return Color(hex: "7FA5C9")
        case 3: return Color(hex: "A8A8A8")
        case 4: return Color(hex: "89C9A0")
        case 5: return Color(hex: "F4D35E")
        default: return .gray
        }
    }

    /// Convert mood value to label
    var moodLabel: String {
        switch self {
        case 1: return "Terrible"
        case 2: return "Bad"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Great"
        default: return "Unknown"
        }
    }
}

// MARK: - String Extensions

extension String {
    /// Format activity ID to display name
    var activityDisplayName: String {
        self.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
