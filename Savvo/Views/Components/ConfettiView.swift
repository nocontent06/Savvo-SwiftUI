import SwiftUI

// MARK: - Particle Model

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var color: Color
    var size: Double
    var rotation: Double
    var targetY: Double
    var targetX: Double
    var targetRotation: Double
}

// MARK: - ConfettiView

/// Full-screen confetti celebration overlay.
/// Place in a `ZStack` above all other content with `.allowsHitTesting(false)`.
struct ConfettiView: View {

    @State private var particles: [ConfettiParticle] = []
    @State private var animated = false

    private let particleColors: [Color] = [
        AppColors.primary, AppColors.accent,
        .blue, .red, .purple, .pink, .yellow, .orange
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 0.55)
                        .position(
                            x: animated ? particle.targetX : particle.x,
                            y: animated ? particle.targetY : particle.y
                        )
                        .rotationEffect(.degrees(animated ? particle.targetRotation : particle.rotation))
                        .opacity(animated ? 0 : 1)
                }
            }
            .onAppear {
                spawnParticles(in: geometry.size)
                withAnimation(.easeOut(duration: 2.8)) {
                    animated = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func spawnParticles(in size: CGSize) {
        // Particles begin spread across the top third so they're immediately visible
        particles = (0..<100).map { _ in
            let x = Double.random(in: 0...size.width)
            let y = Double.random(in: 0...(size.height * 0.3))
            return ConfettiParticle(
                x: x,
                y: y,
                color: particleColors.randomElement()!,
                size: Double.random(in: 6...13),
                rotation: Double.random(in: 0...360),
                targetY: size.height + 60,
                targetX: x + Double.random(in: -130...130),
                targetRotation: Double.random(in: 360...1080)
            )
        }
    }
}
