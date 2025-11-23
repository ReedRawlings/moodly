import SwiftUI

/// Goal selection view - user picks primary reason for using app
struct GoalSelectionView: View {
    @State private var selectedGoal: String?
    @State private var templates: [String: OnboardingTemplate] = [:]

    // Icon mapping for each goal
    private let goalIcons: [String: String] = [
        "reduce_stress": "wind",
        "better_sleep": "bed.double",
        "understand_moods": "brain.head.profile",
        "more_energy": "bolt.fill",
        "manage_condition": "heart.text.square"
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
                    ForEach(Array(templates.keys.sorted()), id: \.self) { goalId in
                        if let template = templates[goalId],
                           let icon = goalIcons[goalId] {
                            GoalOption(
                                id: goalId,
                                title: template.goalName,
                                description: template.description,
                                icon: icon,
                                isSelected: selectedGoal == goalId
                            ) {
                                selectedGoal = goalId
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            NavigationLink {
                if let goalId = selectedGoal,
                   let template = templates[goalId] {
                    CategorySelectionView(
                        selectedGoal: goalId,
                        template: template
                    )
                }
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
        .navigationTitle("Step 2 of 5")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadTemplates()
        }
    }

    private func loadTemplates() {
        if let data = JSONLoader.load("OnboardingTemplates", as: OnboardingTemplatesData.self).value {
            templates = data.templates
        }
    }
}

extension Result {
    var value: Success? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
}

/// Single goal option card
struct GoalOption: View {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

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
