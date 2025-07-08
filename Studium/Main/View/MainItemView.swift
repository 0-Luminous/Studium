import SwiftUI

struct MainItemView: View {
    let item: MainItem
    let isDeleting: Bool
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
                        .scaleEffect(isDeleting ? 0.1 : (isPressed ? 0.95 : 1.0))
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
                        .scaleEffect(isDeleting ? 0.1 : (isPressed ? 0.95 : 1.0))
                }

                VStack(spacing: 8) {
                    if item.type != .folder {
                        // Показываем иконку только для не-папок
                        Image(systemName: item.type.iconName(hasCards: (item.cardCount ?? 0) > 0))
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                    }
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
        .scaleEffect(isDeleting ? 0.1 : 1.0)
        .opacity(isDeleting ? 0.0 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDeleting)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            guard !isDeleting else { return }
            onTap()
        }
        .contextMenu {
            if !isDeleting {
                Button(action: {
                    // Haptic feedback при удалении
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        onDelete()
                    }
                }) {
                    Label("Удалить \(item.type.displayName)", systemImage: "trash")
                }
                .foregroundColor(.red)
            }
        }
        .onPressGesture(
            onPress: {
                guard !isDeleting else { return }
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

// Добавляем AnyShape для объединения разных типов Shape
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}