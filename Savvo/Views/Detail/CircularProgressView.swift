import SwiftUI

/// Animated circular progress ring showing the percentage saved toward a goal.
struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 14)
                .frame(width: size, height: size)

            // Fill
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            AppColors.primary.opacity(0.6),
                            AppColors.primary
                        ]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
                .animation(.spring(response: 0.9, dampingFraction: 0.75), value: progress)

            // Center label
            VStack(spacing: 2) {
                Text("\(Int(progress * 100)) %")
                    .font(.system(size: size * 0.21, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("gespart")
                    .font(.system(size: size * 0.09, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}
