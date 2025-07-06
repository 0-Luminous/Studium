import SwiftUI

struct MainItemView: View {
    let item: MainItem
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 12) {
            // Квадратная иконка
            ZStack {
                if item.type == .folder {
                    // Для папок используем большую иконку folder.fill
                    Image(systemName: "folder.fill")
                        .font(.system(size: 120, weight: .medium))
                        .foregroundStyle(item.gradient)
                        .frame(height: 120)
                        .shadow(
                            color: .black.opacity(0.25),
                            radius: isPressed ? 4 : 8,
                            x: 0,
                            y: isPressed ? 2 : 6
                        )
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                } else {
                    // Для модулей оставляем RoundedRectangle
                    RoundedRectangle(cornerRadius: 20)
                        .fill(item.gradient)
                        .frame(height: 120)
                        .shadow(
                            color: .black.opacity(0.25),
                            radius: isPressed ? 4 : 8,
                            x: 0,
                            y: isPressed ? 2 : 6
                        )
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                }

                VStack(spacing: 8) {
                    if item.type != .folder {
                        // Показываем иконку только для не-папок
                        Image(systemName: item.type.iconName)
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                    }

                    // Небольшая дата создания
                    // Text(item.createdAt, style: .date)
                    //     .font(.caption2)
                    //     .foregroundColor(item.type == .folder ? .primary : .white.opacity(0.8))
                }
            }

            // Название
            Text(item.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()

            // Показать меню удаления
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onDelete()
            }
        }
        .onPressGesture(
            onPress: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
            },
            onRelease: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        )
    }
}