import SwiftUI
import SwiftData

/// Category selection view - show recommended tracking categories based on goal
struct CategorySelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let selectedGoal: String

    @State private var selectedCategories: Set<String> = []

    // Placeholder recommended categories (should be loaded from OnboardingTemplates.json)
    private let recommendedCategories = [
        "sleep", "exercise", "work_hours",
        "caffeine", "social_time", "meditation"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("What do you want to track?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 32)

            Text("Based on your goal, we recommend tracking these")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(recommendedCategories, id: \.self) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategories.contains(category)
                        ) {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Button {
                completeOnboarding()
            } label: {
                Text("Complete Setup")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedCategories.isEmpty ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(selectedCategories.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .navigationTitle("Step 2 of 3")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Pre-select all recommended categories
            selectedCategories = Set(recommendedCategories)
        }
    }

    private func completeOnboarding() {
        // Create user profile
        let profile = UserProfile(
            goals: [selectedGoal],
            trackingCategories: Array(selectedCategories),
            onboardingCompleted: true,
            notificationsEnabled: false
        )
        modelContext.insert(profile)

        // Save context
        try? modelContext.save()
    }
}

/// Single category card
struct CategoryCard: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconForCategory(category))
                    .font(.title)
                    .foregroundStyle(isSelected ? .blue : .secondary)

                Text(category.capitalized)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "sleep": return "bed.double"
        case "exercise": return "figure.run"
        case "work_hours": return "briefcase"
        case "caffeine": return "cup.and.saucer"
        case "social_time": return "person.2"
        case "meditation": return "brain.head.profile"
        default: return "circle"
        }
    }
}

#Preview {
    NavigationStack {
        CategorySelectionView(selectedGoal: "reduce_stress")
            .modelContainer(for: [UserProfile.self], inMemory: true)
    }
}
