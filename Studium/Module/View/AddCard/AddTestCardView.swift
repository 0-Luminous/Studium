import SwiftUI

// MARK: - TestCardView

struct AddTestCardView: View {
    let onAdd: (String, String, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var question = ""
    @State private var correctAnswer = ""
    @State private var wrongAnswer1 = ""
    @State private var wrongAnswer2 = ""
    @State private var wrongAnswer3 = ""
    @State private var wrongAnswer4 = ""
    @State private var wrongAnswer5 = ""
    @State private var wrongAnswer6 = ""
    @State private var wrongAnswer7 = ""
    @State private var showExplanation = false
    @State private var explanation = ""
    @State private var showMoreAnswers = false

    private let maxQuestionLimit = 150
    private let maxAnswerLimit = 100
    private let maxExplanationLimit = 150

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    AddCardNavigationBar(
                        onCancel: { dismiss() },
                        onCreate: {
                            let testContent = createTestContent()
                            onAdd(question, testContent, true)
                            dismiss()
                        },
                        isCreateEnabled: isFormValid,
                        createButtonColor: .watermelonRed
                    )
                    headerSection
                    formSection
                    Spacer()
                }
            }
            .background(Color.graphite)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 4) {
            Image(systemName: "checklist")
                .font(.system(size: 40))
                .foregroundColor(.watermelonRed)

            Text("Новый тест")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Создайте карточку с вопросом и вариантами ответов")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: 24) {
            questionField
            correctAnswerField
            wrongAnswersSection
            explanationSection
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Question Field

    private var questionField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.amber)
                    .font(.system(size: 16, weight: .medium))

                Text("Вопрос")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                Text("\(question.count)/\(maxQuestionLimit)")
                    .font(.caption)
                    .foregroundColor(question.count > maxQuestionLimit ? .red : .gray)
            }

            TextField("Введите вопрос для теста", text: $question, axis: .vertical)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(fieldBackground(isEmpty: question.isEmpty, isOverLimit: question.count > maxQuestionLimit))
                .foregroundColor(.white)
                .onChange(of: question) { newValue in
                    if newValue.count > maxQuestionLimit {
                        question = String(newValue.prefix(maxQuestionLimit))
                    }
                }
        }
    }

    // MARK: - Correct Answer Field

    private var correctAnswerField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 16, weight: .medium))

                Text("Правильный ответ")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                Text("\(correctAnswer.count)/\(maxAnswerLimit)")
                    .font(.caption)
                    .foregroundColor(correctAnswer.count > maxAnswerLimit ? .red : .gray)
            }

            TextField("Введите правильный ответ", text: $correctAnswer)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(fieldBackground(isEmpty: correctAnswer.isEmpty, isOverLimit: correctAnswer.count > maxAnswerLimit))
                .foregroundColor(.white)
                .onChange(of: correctAnswer) { newValue in
                    if newValue.count > maxAnswerLimit {
                        correctAnswer = String(newValue.prefix(maxAnswerLimit))
                    }
                }
        }
    }

    // MARK: - Wrong Answers Section

    private var wrongAnswersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 16, weight: .medium))

                Text("Неправильные ответы")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                Text("Минимум 1")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 12) {
                wrongAnswerField(text: $wrongAnswer1, placeholder: "Неправильный вариант 1", isRequired: true)
                wrongAnswerField(text: $wrongAnswer2, placeholder: "Неправильный вариант 2 (опционально)", isRequired: false)
                wrongAnswerField(text: $wrongAnswer3, placeholder: "Неправильный вариант 3 (опционально)", isRequired: false)
                
                if showMoreAnswers {
                    wrongAnswerField(text: $wrongAnswer4, placeholder: "Неправильный вариант 4 (опционально)", isRequired: false)
                    wrongAnswerField(text: $wrongAnswer5, placeholder: "Неправильный вариант 5 (опционально)", isRequired: false)
                    wrongAnswerField(text: $wrongAnswer6, placeholder: "Неправильный вариант 6 (опционально)", isRequired: false)
                    wrongAnswerField(text: $wrongAnswer7, placeholder: "Неправильный вариант 7 (опционально)", isRequired: false)
                }
                
                moreAnswersButton
            }
        }
    }

    // MARK: - Wrong Answer Field Helper

    private func wrongAnswerField(text: Binding<String>, placeholder: String, isRequired: Bool) -> some View {
        HStack {
            TextField(placeholder, text: text)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(fieldBackground(isEmpty: text.wrappedValue.isEmpty && isRequired, isOverLimit: text.wrappedValue.count > maxAnswerLimit))
                .foregroundColor(.white)
                .onChange(of: text.wrappedValue) { newValue in
                    if newValue.count > maxAnswerLimit {
                        text.wrappedValue = String(newValue.prefix(maxAnswerLimit))
                    }
                }

            Text("\(text.wrappedValue.count)/\(maxAnswerLimit)")
                .font(.caption2)
                .foregroundColor(text.wrappedValue.count > maxAnswerLimit ? .red : .gray)
                .frame(width: 50)
        }
    }

    // MARK: - More Answers Button

    private var moreAnswersButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showMoreAnswers.toggle()
            }
        }) {
            HStack {
                Image(systemName: showMoreAnswers ? "minus.circle" : "plus.circle")
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))

                Text(showMoreAnswers ? "Скрыть дополнительные варианты" : "Добавить еще 4 варианта")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)

                Spacer()

                Image(systemName: showMoreAnswers ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Explanation Section

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showExplanation.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.amber)
                            .font(.system(size: 16, weight: .medium))

                        Text("Пояснение к ответу")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: showExplanation ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }

            if showExplanation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Опциональное пояснение")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Spacer()

                        Text("\(explanation.count)/\(maxExplanationLimit)")
                            .font(.caption)
                            .foregroundColor(explanation.count > maxExplanationLimit ? .red : .gray)
                    }

                    TextField("Объясните, почему этот ответ правильный", text: $explanation, axis: .vertical)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(explanationFieldBackground(isOverLimit: explanation.count > maxExplanationLimit))
                        .foregroundColor(.white)
                        .onChange(of: explanation) { newValue in
                            if newValue.count > maxExplanationLimit {
                                explanation = String(newValue.prefix(maxExplanationLimit))
                            }
                        }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Helper Views

    private func fieldBackground(isEmpty: Bool, isOverLimit: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isOverLimit ? Color.red.opacity(0.8) :
                            isEmpty ? Color.gray.opacity(0.3) : Color.watermelonRed.opacity(0.8),
                        lineWidth: 1.5
                    )
            )
    }

    private func explanationFieldBackground(isOverLimit: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isOverLimit ? Color.red.opacity(0.8) : Color.amber.opacity(0.8),
                        lineWidth: 1.5
                    )
            )
    }

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.098, green: 0.098, blue: 0.098),
                Color(red: 0.078, green: 0.078, blue: 0.078),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        // Форма валидна, если есть вопрос, правильный ответ и минимум один неправильный ответ
        !question.isEmpty && 
        !correctAnswer.isEmpty && 
        !wrongAnswer1.isEmpty &&
        question.count <= maxQuestionLimit && 
        correctAnswer.count <= maxAnswerLimit &&
        wrongAnswer1.count <= maxAnswerLimit &&
        wrongAnswer2.count <= maxAnswerLimit &&
        wrongAnswer3.count <= maxAnswerLimit &&
        wrongAnswer4.count <= maxAnswerLimit &&
        wrongAnswer5.count <= maxAnswerLimit &&
        wrongAnswer6.count <= maxAnswerLimit &&
        wrongAnswer7.count <= maxAnswerLimit &&
        explanation.count <= maxExplanationLimit
    }

    // MARK: - Helper Methods

    private func createTestContent() -> String {
        var content = "ПРАВИЛЬНЫЙ: \(correctAnswer)\n"
        content += "НЕПРАВИЛЬНЫЕ: \(wrongAnswer1)"
        
        if !wrongAnswer2.isEmpty {
            content += ", \(wrongAnswer2)"
        }
        if !wrongAnswer3.isEmpty {
            content += ", \(wrongAnswer3)"
        }
        if !wrongAnswer4.isEmpty {
            content += ", \(wrongAnswer4)"
        }
        if !wrongAnswer5.isEmpty {
            content += ", \(wrongAnswer5)"
        }
        if !wrongAnswer6.isEmpty {
            content += ", \(wrongAnswer6)"
        }
        if !wrongAnswer7.isEmpty {
            content += ", \(wrongAnswer7)"
        }
        
        if !explanation.isEmpty {
            content += "\nПОЯСНЕНИЕ: \(explanation)"
        }
        
        return content
    }
}

// MARK: - Preview

#Preview {
    AddTestCardView { question, content, isBothSides in
        print("Created test: \(question)")
        print("Content: \(content)")
        print("Both sides: \(isBothSides)")
    }
} 