import SwiftUI
import SwiftData

/// Main analytics/insights view showing correlations and patterns
struct InsightsView: View {
    @Query private var moodEntries: [MoodEntry]
    @Query private var correlations: [ActivityCorrelation]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if moodEntries.count < 10 {
                        // Not enough data state
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)

                            Text("Keep tracking!")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("We need at least 10 entries to show meaningful insights. You have \(moodEntries.count).")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 60)
                    } else {
                        // Insights sections
                        CurrentWeekSummarySection(entries: moodEntries)

                        TopPerformersSection(correlations: correlations)

                        PatternsDetectedSection(entries: moodEntries)
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
        }
    }
}

/// Current week summary section
struct CurrentWeekSummarySection: View {
    let entries: [MoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            HStack {
                StatCard(title: "Avg Mood", value: "3.5")
                StatCard(title: "Entries", value: "5")
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Top performing activities section
struct TopPerformersSection: View {
    let correlations: [ActivityCorrelation]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Performers")
                .font(.headline)

            if correlations.isEmpty {
                Text("Activities with highest success rates will appear here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(correlations.prefix(3)) { correlation in
                    CorrelationCard(correlation: correlation)
                }
            }
        }
    }
}

struct CorrelationCard: View {
    let correlation: ActivityCorrelation

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(correlation.activityId.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(Int(correlation.successRate * 100))% success rate (\(correlation.timesObserved) times)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .foregroundStyle(.green)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

/// Patterns detected section
struct PatternsDetectedSection: View {
    let entries: [MoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patterns Detected")
                .font(.headline)

            Text("Pattern detection will analyze your mood trends")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
        }
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [MoodEntry.self, ActivityCorrelation.self], inMemory: true)
}
