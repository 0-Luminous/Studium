import SwiftUI

// MARK: - Study Test Card View Structure

struct StudyTestCardView: View {
    let task: ShortCardModel
    let width: CGFloat
    let height: CGFloat
    @Binding var cardOffset: CGSize
    @Binding var isDragging: Bool
    let currentCardIndex: Int
    let isTransitioning: Bool
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void

    @State private var isFlipped = false
    @State private var selectedAnswer: String? = nil
    @State private var showExplanation = false

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
            // Лицевая сторона (тест)
            testFrontView(textOpacity: textOpacity)
                .opacity(isFlipped ? 0.0 : 1.0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Задняя сторона (пояснение)
            testBackView(textOpacity: textOpacity)
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
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedAnswer)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showExplanation)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isDragging else { return }
            
            // Если уже выбран ответ и показано пояснение, переворачиваем карточку
            if selectedAnswer != nil && showExplanation {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                    isFlipped.toggle()
                }
            } else if isFlipped {
                // Переворачиваем обратно если показано пояснение
                withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                    isFlipped = false
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }

    // MARK: - Test Front View

    private func testFrontView(textOpacity: Double) -> some View {
        VStack(spacing: 16) {
            Spacer()

            // Вопрос с кнопкой пояснения
            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 12) {
                    Text("Тест")
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
                .frame(maxWidth: .infinity, alignment: .center)

                // Кнопка с лампочкой для показа пояснения
                if showExplanation && hasExplanation {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                        .opacity(textOpacity)
                        .transition(.opacity.combined(with: .scale))
                }
            }

            // Варианты ответов
            if !task.description.isEmpty {
                VStack(spacing: 12) {
                    ForEach(parseTestAnswers(task.description), id: \.self) { answer in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedAnswer = answer.text
                                showExplanation = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Показываем результат только если ответ выбран
                                if selectedAnswer == answer.text {
                                    Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(answer.isCorrect ? .green : .red)
                                        .opacity(textOpacity)
                                } else {
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                                        .frame(width: 16, height: 16)
                                        .opacity(textOpacity)
                                }

                                Text(answer.text)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .opacity(textOpacity)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        selectedAnswer == answer.text
                                            ? (answer.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                            : Color.white.opacity(0.1)
                                    )
                                    .stroke(
                                        selectedAnswer == answer.text
                                            ? (answer.isCorrect ? Color.green : Color.red)
                                            : Color.white.opacity(0.3),
                                        lineWidth: selectedAnswer == answer.text ? 2 : 1
                                    )
                            )
                        }
                        .disabled(selectedAnswer != nil)
                    }
                }
            }

            Spacer()

            // Подсказки (только на первой карточке)
            if !isDragging && currentCardIndex == 0 {
                VStack(spacing: 8) {
                    // Подсказка о выборе ответа
                    if selectedAnswer == nil {
                        VStack(spacing: 6) {
                            Image(systemName: "hand.tap")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.4))
                                .opacity(textOpacity)

                            Text("Выберите правильный ответ")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                                .opacity(textOpacity)
                        }
                        .padding(.bottom, 8)
                    } else if hasExplanation {
                        VStack(spacing: 6) {
                            Image(systemName: "hand.tap")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.4))
                                .opacity(textOpacity)

                            Text("Нажмите, чтобы увидеть пояснение")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                                .opacity(textOpacity)
                        }
                        .padding(.bottom, 8)
                    }

                    // Подсказка о свайпах
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
                }
            }
        }
        .padding(24)
        .frame(width: width, height: height)
        .background(cardBackground(color: .purple))
    }

    // MARK: - Test Back View

    private func testBackView(textOpacity: Double) -> some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.yellow)
                        .opacity(textOpacity)

                    Text("Пояснение")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                        .opacity(textOpacity)
                }

                if let explanation = getExplanation() {
                    Text(explanation)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(textOpacity)
                } else {
                    Text("Пояснение не добавлено")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                }
            }

            Spacer()

            // Подсказки (только на первой карточке)
            if !isDragging && currentCardIndex == 0 {
                VStack(spacing: 8) {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.4))
                            .opacity(textOpacity)

                        Text("Нажмите, чтобы вернуться к тесту")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .opacity(textOpacity)
                    }
                    .padding(.bottom, 8)

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
                }
            }
        }
        .padding(24)
        .frame(width: width, height: height)
        .background(cardBackground(color: .indigo))
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

    // MARK: - Helper Properties and Methods

    private var hasExplanation: Bool {
        getExplanation() != nil
    }

    private func getExplanation() -> String? {
        let lines = task.description.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("ПОЯСНЕНИЕ: ") {
                let explanation = String(line.dropFirst("ПОЯСНЕНИЕ: ".count))
                return explanation.isEmpty ? nil : explanation
            }
        }
        return nil
    }

    private func parseTestAnswers(_ content: String) -> [TestAnswer] {
        var answers: [TestAnswer] = []
        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            if line.hasPrefix("ПРАВИЛЬНЫЙ: ") {
                let answerText = String(line.dropFirst("ПРАВИЛЬНЫЙ: ".count))
                answers.append(TestAnswer(text: answerText, isCorrect: true))
            } else if line.hasPrefix("НЕПРАВИЛЬНЫЕ: ") {
                let wrongAnswersText = String(line.dropFirst("НЕПРАВИЛЬНЫЕ: ".count))
                let wrongAnswers = wrongAnswersText.components(separatedBy: ", ")
                for wrongAnswer in wrongAnswers {
                    if !wrongAnswer.trimmingCharacters(in: .whitespaces).isEmpty {
                        answers.append(TestAnswer(text: wrongAnswer.trimmingCharacters(in: .whitespaces), isCorrect: false))
                    }
                }
            }
        }

        return answers
    }
}

 