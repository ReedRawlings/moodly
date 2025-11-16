import SwiftUI

/// 5-point mood picker with emoji visualization
struct MoodPickerView: View {
    @Binding var selectedMood: Int?

    private let moodOptions: [(mood: Int, emoji: String, label: String, color: Color)] = [
        (1, "😞", "Terrible", Color(hex: "9B7EBD")),
        (2, "😕", "Bad", Color(hex: "7FA5C9")),
        (3, "😐", "Okay", Color(hex: "A8A8A8")),
        (4, "🙂", "Good", Color(hex: "89C9A0")),
        (5, "😄", "Great", Color(hex: "F4D35E"))
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("How are you feeling?")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                ForEach(moodOptions, id: \.mood) { option in
                    MoodButton(
                        mood: option.mood,
                        emoji: option.emoji,
                        label: option.label,
                        color: option.color,
                        isSelected: selectedMood == option.mood
                    ) {
                        selectedMood = option.mood
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MoodButton: View {
    let mood: Int
    let emoji: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 40))

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.3) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MoodPickerView(selectedMood: .constant(3))
}
