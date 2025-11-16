import SwiftUI
import SwiftData

/// Main mood entry view - allows users to log their mood with activities and optional details
struct MoodEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    @State private var selectedMood: Int?
    @State private var selectedActivities: Set<String> = []
    @State private var journalText: String = ""
    @State private var sleepHours: Double?
    @State private var energyLevel: Int?
    @State private var showingOptionalDetails = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Mood Picker
                    MoodPickerView(selectedMood: $selectedMood)

                    // Activity Selector
                    if let profile = userProfiles.first {
                        ActivitySelectorView(
                            trackingCategories: profile.trackingCategories,
                            selectedActivities: $selectedActivities
                        )
                    }

                    // Journal Prompt
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How are you really doing today?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("Write your thoughts...", text: $journalText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(5...10)
                    }
                    .padding(.horizontal)

                    // Optional Details Toggle
                    Button {
                        withAnimation {
                            showingOptionalDetails.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Add more details")
                            Spacer()
                            Image(systemName: showingOptionalDetails ? "chevron.up" : "chevron.down")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal)

                    if showingOptionalDetails {
                        VStack(spacing: 16) {
                            // Sleep hours
                            VStack(alignment: .leading) {
                                Text("Sleep hours")
                                    .font(.subheadline)
                                TextField("Hours", value: $sleepHours, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }

                            // Energy level
                            VStack(alignment: .leading) {
                                Text("Energy level")
                                    .font(.subheadline)
                                Picker("Energy", selection: $energyLevel) {
                                    Text("Not set").tag(nil as Int?)
                                    ForEach(1...5, id: \.self) { level in
                                        Text("\(level)").tag(level as Int?)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Save Button
                    Button {
                        saveMoodEntry()
                    } label: {
                        Text("Save Entry")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedMood != nil ? Color.blue : Color.gray)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(selectedMood == nil)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Mood Entry")
        }
    }

    private func saveMoodEntry() {
        guard let mood = selectedMood else { return }

        let entry = MoodEntry(
            mood: mood,
            activities: Array(selectedActivities),
            journalText: journalText.isEmpty ? nil : journalText,
            sleepHours: sleepHours,
            energyLevel: energyLevel
        )

        modelContext.insert(entry)
        try? modelContext.save()

        // Reset form
        selectedMood = nil
        selectedActivities.removeAll()
        journalText = ""
        sleepHours = nil
        energyLevel = nil
        showingOptionalDetails = false
    }
}

#Preview {
    MoodEntryView()
        .modelContainer(for: [MoodEntry.self, UserProfile.self], inMemory: true)
}
