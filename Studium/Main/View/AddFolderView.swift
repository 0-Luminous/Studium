//
//  AddFolderView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct AddFolderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var folderName = ""
    @FocusState private var isTextFieldFocused: Bool
    
    let onCreateFolder: (String) -> Void
    
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
                    Text("Создать папку")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Организуйте свои модули в папки")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Превью папки
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                                
                                Text(folderName.isEmpty ? "Название папки" : folderName)
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Название")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    TextField("Введите название папки", text: $folderName)
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
                                                ? Color.orange.opacity(0.7) 
                                                : Color.clear, 
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .focused($isTextFieldFocused)
                        .foregroundColor(.white)
                        .onSubmit {
                            if !folderName.isEmpty {
                                // Тактильная обратная связь
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                onCreateFolder(folderName)
                                dismiss()
                            }
                        }
                }
                .padding(.horizontal, 20)
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
                        
                        onCreateFolder(folderName)
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 18))
                            Text("Создать папку")
                        }
                    }
                    .modifier(ButtonModifier(isDisabled: folderName.isEmpty, color: .accentColor))
                    .disabled(folderName.isEmpty)
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
    AddFolderView { name in
        print("Created folder: \(name)")
    }
} 