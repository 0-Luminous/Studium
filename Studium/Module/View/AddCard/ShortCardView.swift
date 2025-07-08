import SwiftUI


// MARK: - ShortCardView

struct ShortCardView: View {
    let cardType: CardType
    let onAdd: (String, String, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var isBothSides = true
    
    private let maxCharacterLimit = 95

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
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 4) {
            Image(systemName: "text.alignleft")
                .font(.system(size: 40))
                .foregroundColor(.kiwi)
            
            Text("Новая карточка")
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

            TextField("Введите внешнюю сторону карточки", text: $title)
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

            TextField(
                "Введите внутреннюю сторону карточки",
                text: $content,
                axis: .vertical
            )
            .font(.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(fieldBackground(isEmpty: content.isEmpty, isOverLimit: content.count > maxCharacterLimit))
            .foregroundColor(.white)
            .lineLimit(3...8)
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
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Карточка в обе стороны")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text("Карточка может появиться любой стороной в игре")
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
            createButton
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    // MARK: - Create Button
    private var createButton: some View {
        Button(action: {
            onAdd(title, content, isBothSides)
            dismiss()
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                
                Text("Создать карточку")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(createButtonBackground)
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
    
    private var createButtonBackground: some View {
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
                Color(red: 0.078, green: 0.078, blue: 0.078)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !title.isEmpty && !content.isEmpty && 
        title.count <= maxCharacterLimit && content.count <= maxCharacterLimit
    }
}
