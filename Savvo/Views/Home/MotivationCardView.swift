import SwiftUI

/// Weekly motivation card shown at the top of the home screen.
struct MotivationCardView: View {
    let message: String
    let streakWeeks: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Deine Motivation diese Woche")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.80))
                        .textCase(.uppercase)
                        .kerning(0.5)

                    Text(message)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Text("🌟")
                    .font(.system(size: 28))
            }

            if streakWeeks > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 13))
                    Text(streakWeeks == 1
                         ? "1 Woche in Folge gespart! 🔥"
                         : "\(streakWeeks) Wochen in Folge gespart! 🔥")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.18))
                .cornerRadius(20)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.primary,
                    AppColors.primary.opacity(0.72)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(22)
        .shadow(color: AppColors.primary.opacity(0.28), radius: 14, x: 0, y: 6)
    }
}
