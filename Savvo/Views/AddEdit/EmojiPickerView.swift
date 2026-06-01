import SwiftUI

/// Grid-based emoji picker.
struct EmojiPickerView: View {
    @Binding var selectedEmoji: String

    private let columns = [GridItem(.adaptive(minimum: 52), spacing: 6)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Emoji wählen")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Constants.defaultEmojis, id: \.self) { emoji in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedEmoji = emoji
                        }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(width: 52, height: 52)
                            .background(
                                selectedEmoji == emoji
                                    ? AppColors.primary.opacity(0.14)
                                    : Color(.systemGray6)
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedEmoji == emoji ? AppColors.primary : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(emoji)
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
