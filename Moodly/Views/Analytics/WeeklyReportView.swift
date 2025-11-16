import SwiftUI
import SwiftData

/// Weekly summary report view
struct WeeklyReportView: View {
    @Query private var moodEntries: [MoodEntry]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Weekly report view placeholder")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("Will show:")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Week-over-week comparison")
                        Text("• Most/least frequent activities")
                        Text("• Mood trends chart")
                        Text("• Personalized suggestions")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Weekly Report")
        }
    }
}

#Preview {
    WeeklyReportView()
        .modelContainer(for: [MoodEntry.self], inMemory: true)
}
