import SwiftUI
import SwiftData

/// Category selection view - show recommended tracking categories based on goal
struct CategorySelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let selectedGoal: String
    let template: OnboardingTemplate

    @State private var selectedCategories: Set<String> = []
    @State private var activities: [Activity] = []
    @State private var showTip: String?

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

            // Educational tip display
            if let tip = showTip {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(tip)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(template.recommendedCategories, id: \.self) { categoryId in
                        if let activity = activities.first(where: { $0.id == categoryId }) {
                            CategoryCard(
                                activity: activity,
                                isSelected: selectedCategories.contains(categoryId),
                                tip: template.educationalTips.first(where: { $0.category == categoryId })?.tip
                            ) {
                                toggleCategory(categoryId)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            NavigationLink {
                NotificationSetupView(
                    selectedGoal: selectedGoal,
                    selectedCategories: Array(selectedCategories)
                )
            } label: {
                Text("Continue")
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
        .navigationTitle("Step 3 of 5")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadActivities()
            // Pre-select all recommended categories
            selectedCategories = Set(template.recommendedCategories)
        }
    }

    private func loadActivities() {
        if let data = JSONLoader.load("Activities", as: ActivitiesData.self).value {
            activities = data.activities
        }
    }

    private func toggleCategory(_ categoryId: String) {
        if selectedCategories.contains(categoryId) {
            selectedCategories.remove(categoryId)
            showTip = nil
        } else {
            selectedCategories.insert(categoryId)
            // Show tip when selecting
            if let tip = template.educationalTips.first(where: { $0.category == categoryId })?.tip {
                showTip = tip
                // Hide tip after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if showTip == tip {
                        showTip = nil
                    }
                }
            }
        }
    }
}

/// Single category card
struct CategoryCard: View {
    let activity: Activity
    let isSelected: Bool
    let tip: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: activity.icon)
                        .font(.title)
                        .foregroundStyle(isSelected ? .blue : .secondary)
                        .frame(maxWidth: .infinity)

                    // Show info icon if there's a tip
                    if tip != nil {
                        Image(systemName: "info.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                            .offset(x: 8, y: -8)
                    }
                }

                Text(activity.name)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
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
}

#Preview {
    NavigationStack {
        CategorySelectionView(selectedGoal: "reduce_stress")
            .modelContainer(for: [UserProfile.self], inMemory: true)
    }
}
