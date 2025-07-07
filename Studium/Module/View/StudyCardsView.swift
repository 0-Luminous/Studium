//
//  StudyCardsView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct StudyCardsView: View {
    let tasks: [ModuleTask]
    @Environment(\.dismiss) private var dismiss
    @State private var currentCardIndex = 0
    @State private var showingAnswer = false
    
    private var currentTask: ModuleTask? {
        guard !tasks.isEmpty, currentCardIndex < tasks.count else { return nil }
        return tasks[currentCardIndex]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Прогресс
                HStack {
                    Text("\(currentCardIndex + 1) из \(tasks.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Завершить") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.2))
                
                // Карточка
                if let task = currentTask {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            // Заголовок карточки
                            Text(task.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Контент карточки
                            if !task.description.isEmpty {
                                Text(task.description)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .opacity(showingAnswer ? 1.0 : 0.3)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Кнопка показать ответ
                        if !showingAnswer && !task.description.isEmpty {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showingAnswer = true
                                }
                            }) {
                                Text("Показать ответ")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.accentColor)
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        // Кнопки навигации
                        HStack(spacing: 16) {
                            Button(action: {
                                previousCard()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Назад")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .disabled(currentCardIndex == 0)
                            .opacity(currentCardIndex == 0 ? 0.5 : 1.0)
                            
                            Button(action: {
                                nextCard()
                            }) {
                                HStack {
                                    Text("Далее")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.accentColor)
                                )
                            }
                            .disabled(currentCardIndex == tasks.count - 1)
                            .opacity(currentCardIndex == tasks.count - 1 ? 0.5 : 1.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                } else {
                    // Пустое состояние
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .opacity(0.6)
                        
                        Text("Нет карточек для изучения")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
            }
            .background(Color(red: 0.098, green: 0.098, blue: 0.098))
            .navigationBarHidden(true)
        }
    }
    
    private func nextCard() {
        if currentCardIndex < tasks.count - 1 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentCardIndex += 1
                showingAnswer = false
            }
        }
    }
    
    private func previousCard() {
        if currentCardIndex > 0 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentCardIndex -= 1
                showingAnswer = false
            }
        }
    }
}

#Preview {
    let sampleTasks = [
        ModuleTask(
            title: "Что такое Swift?", 
            description: "Swift - это мощный и интуитивно понятный язык программирования для iOS, macOS, watchOS и tvOS.",
            isCompleted: false,
            cardType: .regular,
            isBothSides: true,
            moduleId: UUID()
        ),
        ModuleTask(
            title: "Что такое Optional?", 
            description: "Optional - это тип данных, который может содержать значение или nil.",
            isCompleted: false,
            cardType: .regular,
            isBothSides: true,
            moduleId: UUID()
        )
    ]
    
    StudyCardsView(tasks: sampleTasks)
} 