import SwiftUI

/// Goal selection view - user picks primary reason for using app
struct GoalSelectionView: View {
    @State private var selectedGoal: String?

    private let goals = [
        ("reduce_stress", "Reduce stress and anxiety", "wind"),
        ("better_sleep", "Improve sleep quality", "bed.double"),
        ("understand_moods", "Understand mood swings", "brain.head.profile"),
        ("more_energy", "Increase energy levels", "bolt.fill"),
        ("manage_condition", "Manage chronic condition", "heart.text.square")
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("What's your main goal?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 32)

            Text("We'll customize tracking based on your goal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(goals, id: \.0) { goal in
                        GoalOption(
                            id: goal.0,
                            title: goal.1,
                            icon: goal.2,
                            isSelected: selectedGoal == goal.0
                        ) {
                            selectedGoal = goal.0
                        }
                    }
                }
                .padding(.horizontal)
            }

            NavigationLink {
                CategorySelectionView(selectedGoal: selectedGoal ?? "reduce_stress")
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedGoal != nil ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(selectedGoal == nil)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .navigationTitle("Step 1 of 3")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Single goal option card
struct GoalOption: View {
    let id: String
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .blue : .secondary)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

#Preview {
    NavigationStack {
        GoalSelectionView()
    }
}
