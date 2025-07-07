import SwiftUI


// MARK: - ModuleTaskView

struct ModuleTaskView: View {
    let task: ModuleTask
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false
    @State private var isFlipped = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Front Side
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .strikethrough(task.isCompleted)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                task.isCompleted
                                    ? Color.gray.opacity(0.25)
                                    : Color.accentColor.opacity(0.85),
                                task.isCompleted
                                    ? Color.gray.opacity(0.18)
                                    : Color.accentColor.opacity(0.65)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(task.isCompleted ? 0.08 : 0.18),
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 6
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isFlipped ? 0.0 : 1.0)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isFlipped)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)

            // Back Side
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(!task.description.isEmpty ? task.description : "Нет описания")
                        .font(.system(size: 14))
                        .foregroundColor(!task.description.isEmpty ? .white : .gray)
                        .lineLimit(6)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                task.isCompleted
                                    ? Color.gray.opacity(0.25)
                                    : Color.accentColor.opacity(0.85),
                                task.isCompleted
                                    ? Color.gray.opacity(0.18)
                                    : Color.accentColor.opacity(0.65)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(task.isCompleted ? 0.08 : 0.18),
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 6
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isFlipped ? 1.0 : 0.0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isFlipped)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)

            // Индикатор "в обе стороны" (только на лицевой стороне)
            if task.isBothSides && !isFlipped {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption2)
                }
                .padding(.trailing, 10)
                .padding(.vertical, 4)
                .padding([.bottom, .leading], 10)
                .transition(.scale)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            // Долгое нажатие — отметить как выполнено
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onToggle()
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
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