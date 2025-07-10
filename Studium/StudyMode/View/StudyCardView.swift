import SwiftUI

// MARK: - Card View Structure

struct StudyCardView: View {
    let task: ShortCardModel
    let width: CGFloat
    let height: CGFloat
    @Binding var isFlipped: Bool
    @Binding var cardOffset: CGSize
    @Binding var isDragging: Bool
    let currentCardIndex: Int
    let isTransitioning: Bool
    let onTap: () -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void

    var body: some View {
        let rawRotationAngle = -cardOffset.width / 10
        let rotationAngle = min(max(rawRotationAngle, -30), 30)
        let isAtRotationLimit = abs(rawRotationAngle) > 30
        let limitScale = isAtRotationLimit ? 0.75 : 1.0
        let baseScale = 1.0 - abs(cardOffset.width) / 1000
        let finalRotation = Double(rotationAngle)
        let finalScale = baseScale * limitScale
        let textOpacity = isAtRotationLimit ? 0.3 : 1.0

        return ZStack {
            // Лицевая сторона (вопрос)
            cardFrontView(textOpacity: textOpacity)
                .opacity(isFlipped ? 0.0 : 1.0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Задняя сторона (ответ)
            cardBackView(textOpacity: textOpacity)
                .opacity(isFlipped ? 1.0 : 0.0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .offset(x: cardOffset.width, y: 0)
        .scaleEffect(isDragging ? max(0.85, finalScale) : 1.0)
        .rotation3DEffect(
            .degrees(Double(finalRotation)),
            axis: (x: 0, y: 1, z: 0)
        )
        .opacity(isTransitioning ? 0.0 : 1.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.9), value: isFlipped)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: isDragging)
        .animation(.spring(response: 0.7, dampingFraction: 0.85), value: isTransitioning)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isDragging {
                onTap()
            }
        }
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }

    // MARK: - Card Front View

    private func cardFrontView(textOpacity: Double) -> some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 12) {
                Text("Вопрос")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .opacity(textOpacity)

                Text(task.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(textOpacity)
            }

            Spacer()

            // Подсказка о нажатии (только на первой карточке)
            if !task.description.isEmpty && !isDragging && currentCardIndex == 0 {
                VStack(spacing: 6) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(textOpacity)

                    Text("Нажмите, чтобы увидеть ответ")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                        .opacity(textOpacity)
                }
                .padding(.bottom, 16)
            }

            // Подсказка о свайпах (только на первой карточке)
            if !isDragging && currentCardIndex == 0 {
                VStack(spacing: 6) {
                    HStack(spacing: 12) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.3))
                            .opacity(textOpacity)

                        Text("Свайп для навигации")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                            .opacity(textOpacity)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.3))
                            .opacity(textOpacity)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding(24)
        .frame(width: width, height: height)
        .background(cardBackground(color: .accentColor))
    }

    // MARK: - Card Back View

    private func cardBackView(textOpacity: Double) -> some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 12) {
                Text("Ответ")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .opacity(textOpacity)

                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(textOpacity)
                } else {
                    Text("Нет ответа")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                }
            }

            Spacer()

            // Подсказка о нажатии обратно (только на первой карточке)
            if !isDragging && currentCardIndex == 0 {
                VStack(spacing: 6) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(textOpacity)

                    Text("Нажмите, чтобы вернуться к вопросу")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                        .opacity(textOpacity)
                }
                .padding(.bottom, 16)
            }

            // Подсказка о свайпах (только на первой карточке)
            if !isDragging && currentCardIndex == 0 {
                VStack(spacing: 6) {
                    HStack(spacing: 12) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.3))
                            .opacity(textOpacity)

                        Text("Свайп для навигации")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                            .opacity(textOpacity)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.3))
                            .opacity(textOpacity)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding(24)
        .frame(width: width, height: height)
        .background(cardBackground(color: .green))
    }

    // MARK: - Card Background

    private func cardBackground(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(0.15),
                        color.opacity(0.08),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .stroke(
                LinearGradient(
                    colors: [
                        color.opacity(0.3),
                        color.opacity(0.1),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
    }
}