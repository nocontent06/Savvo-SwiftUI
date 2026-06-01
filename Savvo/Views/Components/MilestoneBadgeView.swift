import SwiftUI

/// Badge shown when a savings milestone (25 / 50 / 75 / 100 %) is reached.
struct MilestoneBadgeView: View {
    let milestone: Int

    var badgeColor: Color {
        switch milestone {
        case 25:  return Color.blue
        case 50:  return AppColors.accent
        case 75:  return AppColors.primary
        case 100: return Color(hex: "FFD700") // Gold
        default:  return Color.gray
        }
    }

    var badgeEmoji: String {
        switch milestone {
        case 25:  return "🥉"
        case 50:  return "🥈"
        case 75:  return "🥇"
        case 100: return "🏆"
        default:  return "🎖️"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(badgeEmoji)
                .font(.caption)
            Text("\(milestone) %")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor)
        .cornerRadius(12)
    }
}
