import SwiftUI

/// Welcome screen - explains app value proposition
struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // App icon/logo placeholder
                Image(systemName: "face.smiling.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Welcome to Moodly")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Track your mood and get actionable insights to improve your mental wellbeing")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)

                Spacer()

                NavigationLink {
                    GoalSelectionView()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationTitle("Step 1 of 5")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    WelcomeView()
}
