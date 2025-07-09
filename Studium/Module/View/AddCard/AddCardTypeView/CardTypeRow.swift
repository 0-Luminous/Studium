import SwiftUI

struct CardTypeRow: View {
    let cardType: CardType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Иконка
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cardType.gradient)
                        .frame(width: 60, height: 60)

                    Image(systemName: cardType.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

                // Информация
                VStack(alignment: .leading, spacing: 6) {
                    Text(cardType.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(cardType.description)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                }

                // Индикатор выбора
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .green : .gray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(isSelected ? 0.12 : 0.06))
                    .stroke(
                        isSelected ? Color.accentColor : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.3) : Color.black.opacity(0.1),
                radius: isSelected ? 8 : 2,
                x: 0, y: isSelected ? 4 : 2
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}