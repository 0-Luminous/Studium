import SwiftUI

// MARK: - TestCardView

struct TestCardView: View {
    let task: ShortCardModel
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    let isDeleting: Bool

    @State private var isPressed = false
    @State private var isFlipped = false
    @State private var selectedAnswer: String? = nil
    @State private var showExplanation = false
    
    var body: some View {
        ZStack {
            // Front Side - Тест
            VStack(spacing: 6) {
                
                // Вопрос
                Text(task.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .frame(minHeight: 30)
                    .padding(.bottom, 8)
                
                // Варианты ответов
                if !task.description.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(parseTestAnswers(task.description), id: \.self) { answer in
                            Button(action: {
                                selectedAnswer = answer.text
                                showExplanation = true
                            }) {
                                HStack(spacing: 10) {
                                    // Показываем результат только если ответ выбран
                                    if selectedAnswer == answer.text {
                                        Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(answer.isCorrect ? .green : .red)
                                    } else {
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                            .frame(width: 12, height: 12)
                                    }
                                    
                                    Text(answer.text)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            selectedAnswer == answer.text
                                                ? (answer.isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.8))
                                                : Color.black.opacity(0.5)
                                        )
                                )
                            }
                            .disabled(selectedAnswer != nil)
                        }
                    }
                }
                
                Spacer()
                
                // Кнопка с лампочкой для показа пояснения
                if showExplanation && hasExplanation {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isFlipped.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                            
                            Text("Пояснение")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.charcoal, lineWidth: 2)
                        )
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 20)
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

            // Back Side - Пояснение
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.yellow)
                    
                    Text("Пояснение")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                        .textCase(.uppercase)
                }
                
                if let explanation = getExplanation() {
                    Text(explanation)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                } else {
                    Text("Пояснение не добавлено")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Нажмите чтобы вернуться")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(20)
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
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedAnswer)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showExplanation)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            guard !isDeleting else { return }
            
            // Переворачиваем только если уже показано пояснение
            if isFlipped {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isFlipped = false
                }
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
    
    // MARK: - Helper Properties
    
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
    
    func parseTestAnswers(_ content: String) -> [TestAnswer] {
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

// MARK: - Test Answer Model
struct TestAnswer: Hashable {
    let text: String
    let isCorrect: Bool
} 