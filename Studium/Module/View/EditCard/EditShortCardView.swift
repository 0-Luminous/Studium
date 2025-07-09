import SwiftUI

// MARK: - EditShortCardView

struct EditShortCardView: View {
    let card: ShortCardModel
    let onEdit: (String, String, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var isBothSides = true

    // Увеличиваем лимит для возможности создания широких карточек
    private let maxCharacterLimit = 160

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    formSection
                    Spacer()
                    actionButtons
                }
            }
            .background(backgroundGradient)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            title = card.title
            content = card.description
            isBothSides = card.isBothSides
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 4) {
            Image(systemName: "pencil")
                .font(.system(size: 40))
                .foregroundColor(.kiwi)

            Text("Редактировать карточку")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.top, 20)
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: 24) {
            titleField
            contentField
            bothSidesToggle
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Title Field

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "rectangle.fill")
                    .foregroundColor(.kiwi)
                    .font(.system(size: 16, weight: .medium))

                Text("Внешняя сторона")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                // Счетчик символов для заголовка
                Text("\(title.count)/\(maxCharacterLimit)")
                    .font(.caption)
                    .foregroundColor(title.count > maxCharacterLimit ? .red : .gray)
            }

            TextField("Введите внешнюю сторону карточки", text: $title, axis: .vertical)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(fieldBackground(isEmpty: title.isEmpty, isOverLimit: title.count > maxCharacterLimit))
                .foregroundColor(.white)
                .onChange(of: title) { newValue in
                    if newValue.count > maxCharacterLimit {
                        title = String(newValue.prefix(maxCharacterLimit))
                    }
                }
        }
    }

    // MARK: - Content Field

    private var contentField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "rectangle")
                    .foregroundColor(.kiwi)
                    .font(.system(size: 16, weight: .medium))

                Text("Внутренняя сторона")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                // Счетчик символов для содержимого
                Text("\(content.count)/\(maxCharacterLimit)")
                    .font(.caption)
                    .foregroundColor(content.count > maxCharacterLimit ? .red : .gray)
            }

            TextField("Введите внутреннюю сторону карточки", text: $content, axis: .vertical)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(fieldBackground(isEmpty: content.isEmpty, isOverLimit: content.count > maxCharacterLimit))
                .foregroundColor(.white)
                .onChange(of: content) { newValue in
                    if newValue.count > maxCharacterLimit {
                        content = String(newValue.prefix(maxCharacterLimit))
                    }
                }
        }
    }

    // MARK: - Both Sides Toggle

    private var bothSidesToggle: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.kiwi)
                    .font(.system(size: 16, weight: .medium))

                Text("Настройки карточки")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }

            // Индикатор размера карточки
            if !title.isEmpty || !content.isEmpty {
                HStack {
                    Image(systemName: willBeWideCard ? "rectangle.split.2x1" : "rectangle")
                        .foregroundColor(willBeWideCard ? .orange : .blue)
                        .font(.system(size: 14, weight: .medium))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(willBeWideCard ? "Широкая карточка" : "Обычная карточка")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(willBeWideCard ? .orange : .blue)

                        Text(cardSizeReason)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(willBeWideCard ? Color.orange.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Карточка в обе стороны")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)

                    Text("Карточка может появиться любой стороной")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Toggle("", isOn: $isBothSides)
                    .toggleStyle(SwitchToggleStyle(tint: .kiwi))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.kiwi.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            cancelButton
            saveButton
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: {
            onEdit(title, content, isBothSides)
            dismiss()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .medium))

                Text("Сохранить")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(saveButtonBackground)
            .shadow(
                color: isFormValid ? .blue.opacity(0.4) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(!isFormValid)
        .scaleEffect(isFormValid ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isFormValid)
    }

    // MARK: - Cancel Button

    private var cancelButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Отмена")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
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
                            isEmpty ? Color.gray.opacity(0.3) : Color.blue.opacity(0.8),
                        lineWidth: 1.5
                    )
            )
    }

    private var saveButtonBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(
                isFormValid
                    ? LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
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
        // Форма валидна, если поля не пустые и не превышают лимит
        !title.isEmpty && !content.isEmpty &&
            title.count <= maxCharacterLimit && content.count <= maxCharacterLimit
    }

    // Проверяем размер карточки на основе каждой стороны отдельно
    private var willBeWideCard: Bool {
        title.count > 95 || content.count > 95
    }

    // Определяем, какая сторона делает карточку широкой
    private var cardSizeReason: String {
        if title.count > 95 && content.count > 95 {
            return "Обе стороны >95 символов"
        } else if title.count > 95 {
            return "Внешняя сторона >95 символов"
        } else if content.count > 95 {
            return "Внутренняя сторона >95 символов"
        } else {
            return "Обе стороны ≤95 символов"
        }
    }
}