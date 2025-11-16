import SwiftUI

/// Grid of activity icons for multi-select tracking
struct ActivitySelectorView: View {
    let trackingCategories: [String]
    @Binding var selectedActivities: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activities")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(trackingCategories, id: \.self) { activity in
                    ActivityButton(
                        activity: activity,
                        isSelected: selectedActivities.contains(activity)
                    ) {
                        if selectedActivities.contains(activity) {
                            selectedActivities.remove(activity)
                        } else {
                            selectedActivities.insert(activity)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityButton: View {
    let activity: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconForActivity(activity))
                    .font(.title3)
                    .foregroundStyle(isSelected ? .blue : .secondary)

                Text(activity.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }

    private func iconForActivity(_ activity: String) -> String {
        switch activity {
        case "sleep": return "bed.double"
        case "exercise": return "figure.run"
        case "work_hours", "work": return "briefcase"
        case "caffeine": return "cup.and.saucer"
        case "social_time": return "person.2"
        case "meditation": return "brain.head.profile"
        case "friends": return "person.3"
        case "family": return "house"
        case "reading": return "book"
        case "music": return "music.note"
        case "nature": return "leaf"
        case "therapy": return "heart.text.square"
        default: return "circle"
        }
    }
}

#Preview {
    ActivitySelectorView(
        trackingCategories: ["sleep", "exercise", "work_hours", "caffeine", "social_time", "meditation"],
        selectedActivities: .constant(["exercise", "sleep"])
    )
}
