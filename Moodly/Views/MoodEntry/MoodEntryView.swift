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
                VStack(spacing: 16) {
                    // HERO: Mood Picker - Most important
                    MoodPickerView(selectedMood: $selectedMood)

                    // HERO: Activity Selector - Second most important
                    if let profile = userProfiles.first {
                        ActivitySelectorView(
                            trackingCategories: profile.trackingCategories,
                            selectedActivities: $selectedActivities
                        )
                    }

                    // Divider for visual hierarchy
                    Divider()
                        .padding(.horizontal)

                    // Context-aware sleep tracking (show prominently if morning)
                    if shouldShowSleepProminent {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "bed.double")
                                    .foregroundStyle(.blue)
                                Text("How did you sleep?")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }

                            HStack(spacing: 12) {
                                TextField("Hours", value: $sleepHours, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 100)

                                Text("hours")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }

                    // Subtle journal prompt - optional, less prominent
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Any thoughts? (optional)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)

                        TextField("Write your thoughts...", text: $journalText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding(.horizontal)

                    // Optional Details - collapsed by default
                    if !shouldShowSleepProminent || energyLevel != nil || showingOptionalDetails {
                        VStack(spacing: 0) {
                            Button {
                                withAnimation {
                                    showingOptionalDetails.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("More details")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Image(systemName: showingOptionalDetails ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }

                            if showingOptionalDetails {
                                VStack(spacing: 16) {
                                    // Sleep (if not already shown)
                                    if !shouldShowSleepProminent {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Sleep hours")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            TextField("Hours", value: $sleepHours, format: .number)
                                                .textFieldStyle(.roundedBorder)
                                                .keyboardType(.decimalPad)
                                        }
                                    }

                                    // Energy level
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Energy level")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
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
                                .padding(.top, 8)
                            }
                        }
                    }

                    // Save Button - prominent CTA
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
                    .padding(.top, 8)
                }
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .navigationTitle("Check In")
        }
    }

    /// Show sleep tracking prominently if it's early morning (before 11am)
    private var shouldShowSleepProminent: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 11
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
