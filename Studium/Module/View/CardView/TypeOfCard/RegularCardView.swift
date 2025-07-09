import SwiftUI

// MARK: - RegularCardView

struct RegularCardView: View {
    let task: ShortCardModel
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    let isDeleting: Bool

    @State private var isPressed = false
    @State private var isFlipped = false
    
    // Определяем размер карточки на основе длины текста
    private var cardSize: CardSize {
        let titleLength = task.title.count
        let descriptionLength = task.description.count
        return (titleLength > 85 || descriptionLength > 85) ? .wide : .regular
    }
    
    var body: some View {
        ZStack {
            // Front Side - Вопрос
            VStack(spacing: 8) {
                Text(task.title)
                    .font(.system(size: cardSize == .wide ? 14 : 13, weight: .semibold))
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted)
                    .multilineTextAlignment(.center)
                    .opacity(task.isCompleted ? 0.7 : 1.0)
                    .lineLimit(nil)
            }
            .padding(cardSize == .wide ? 20 : 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        task.isCompleted
                            ? LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.4),
                                    Color.gray.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : task.cardType.gradient
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(task.isCompleted ? 0.1 : 0.2),
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isDeleting ? 0.1 : (isPressed ? 0.95 : 1.0))
            .opacity(isDeleting ? 0.0 : (isFlipped ? 0.0 : 1.0))
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )

            // Back Side - Ответ
            VStack(spacing: 8) {
                Text(!task.description.isEmpty ? task.description : "Нет описания")
                    .font(.system(size: cardSize == .wide ? 14 : 13))
                    .foregroundColor(!task.description.isEmpty ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(cardSize == .wide ? 20 : 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.charcoal.opacity(0.9),
                                Color.grayCharcoal.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(task.cardType.gradient, lineWidth: 2)
            )
            .shadow(
                color: .black.opacity(0.2),
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isDeleting ? 0.1 : (isPressed ? 0.95 : 1.0))
            .opacity(isDeleting ? 0.0 : (isFlipped ? 1.0 : 0.0))
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isFlipped)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: task.isCompleted)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDeleting)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            guard !isDeleting else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            guard !isDeleting else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onToggle()
            }
        }
        .contextMenu {
            if !isDeleting {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        onToggle()
                    }
                }) {
                    Label(task.isCompleted ? "Включить карточку" : "Выключить карточку", 
                          systemImage: task.isCompleted ? "checkmark.circle" : "circle")
                }
                
                Button(action: onEdit) {
                    Label("Редактировать", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: onDelete) {
                    Label("Удалить", systemImage: "trash")
                }
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

// MARK: - CardSize Enum
enum CardSize {
    case regular // До 85 символов включительно на любой стороне
    case wide    // Больше 85 символов на любой стороне
    case test    // Тестовая карточка (2x2)
}

// MARK: - Press Gesture Extension
extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
} 