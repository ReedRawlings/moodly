import SwiftUI
import SwiftData

/// Monthly calendar grid showing mood entries
struct CalendarView: View {
    @Query private var moodEntries: [MoodEntry]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Calendar view coming soon")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding()

                    // Placeholder for calendar implementation
                    Text("Will display:")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Monthly calendar grid")
                        Text("• Mood emoji/color per day")
                        Text("• Tap to see entry details")
                        Text("• Streak indicator")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Calendar")
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [MoodEntry.self], inMemory: true)
}
