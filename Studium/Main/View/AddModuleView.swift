//
//  AddModuleView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct AddModuleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var moduleName = ""
    @State private var selectedGradient = 0
    @State private var moduleDescription = ""
    @FocusState private var isTextFieldFocused: Bool

    let onCreateModule: (String, LinearGradient, String) -> Void
    let onCreateModuleWithIndex: ((String, Int, String) -> Void)?
    
    // MARK: - Initialization
    init(onCreateModule: @escaping (String, LinearGradient, String) -> Void) {
        self.onCreateModule = onCreateModule
        self.onCreateModuleWithIndex = nil
    }
    
    init(onCreateModuleWithIndex: @escaping (String, Int, String) -> Void) {
        self.onCreateModule = { _, _, _ in } // Пустая заглушка
        self.onCreateModuleWithIndex = onCreateModuleWithIndex
    }

    // Предустановленные градиенты для модулей
    private let gradients = [
        LinearGradient(
            gradient: Gradient(colors: [Color.aquaGreen, Color.limeGreen]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.stormBlue, Color.jungleGreen]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.teal]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.oceanBlue, Color.softTeal]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.cyan, Color.blue]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.red, Color.coral]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.watermelonRed, Color.amber]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.neonPink, Color.watermelonRed]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            gradient: Gradient(colors: [Color.lilacGray, Color.cherryRed]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
    ]

    // Модификатор для кнопок
    private struct ButtonModifier: ViewModifier {
        let isSelected: Bool
        let isDisabled: Bool
        let color: Color

        init(isSelected: Bool = false, isDisabled: Bool = false, color: Color = .accentColor) {
            self.isSelected = isSelected
            self.isDisabled = isDisabled
            self.color = color
        }

        func body(content: Content) -> some View {
            content
                .font(.system(size: 16, weight: .medium))
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .foregroundColor(isDisabled ? .gray : .white)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isDisabled ? Color.gray.opacity(0.3) : color
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? color.opacity(0.7) : Color.clear,
                            lineWidth: isSelected ? 1.5 : 0
                        )
                )
                .shadow(
                    color: isSelected ? color.opacity(0.3) : .black.opacity(0.1),
                    radius: 3, x: 0, y: 1
                )
                .opacity(isDisabled ? 0.6 : 1)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Заголовок
                VStack(spacing: 8) {
                    Text("Создать модуль")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Настройте ваш новый модуль обучения")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // Превью модуля
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(gradients[selectedGradient])
                        .frame(height: 140)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)

                                Text(moduleName.isEmpty ? "Название модуля" : moduleName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                // Форма
                VStack(spacing: 24) {
                    // Поле названия
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Название")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)

                        TextField("Введите название модуля", text: $moduleName)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.18, green: 0.18, blue: 0.18))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                isTextFieldFocused
                                                    ? Color.blue.opacity(0.7)
                                                    : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .focused($isTextFieldFocused)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)

                    // Выбор цвета
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Цветовая схема")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0 ..< gradients.count, id: \.self) { index in
                                    Circle()
                                        .fill(gradients[index])
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedGradient == index ? 3 : 0)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                        .scaleEffect(selectedGradient == index ? 1.15 : 1.0)
                                        .shadow(
                                            color: selectedGradient == index
                                                ? Color.accentColor.opacity(0.4)
                                                : .black.opacity(0.1),
                                            radius: selectedGradient == index ? 6 : 2,
                                            x: 0, y: 2
                                        )
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedGradient)
                                        .onTapGesture {
                                            // Тактильная обратная связь
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()

                                            selectedGradient = index
                                        }
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 32)

                Spacer()

                // Кнопки
                HStack(spacing: 16) {
                    Button(action: {
                        // Тактильная обратная связь
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()

                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 18))
                            Text("Отмена")
                        }
                    }
                    .modifier(ButtonModifier(color: .red))

                    Button(action: {
                        // Тактильная обратная связь
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()

                        if let onCreateModuleWithIndex = onCreateModuleWithIndex {
                            onCreateModuleWithIndex(moduleName, selectedGradient, moduleDescription)
                        } else {
                            onCreateModule(moduleName, gradients[selectedGradient], moduleDescription)
                        }
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Создать модуль")
                        }
                    }
                    .modifier(ButtonModifier(isDisabled: moduleName.isEmpty, color: .accentColor))
                    .disabled(moduleName.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.098, green: 0.098, blue: 0.098))
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
        }
    }
}

#Preview {
    AddModuleView(onCreateModule: { name, _, _ in
        print("Created module: \(name)")
    })
}
