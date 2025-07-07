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
    @State private var isFlipped = false
    @State private var cardOffset = CGSize.zero
    
    private var currentTask: ModuleTask? {
        guard !tasks.isEmpty, currentCardIndex < tasks.count else { return nil }
        return tasks[currentCardIndex]
    }
    
    private var progressPercentage: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(currentCardIndex + 1) / Double(tasks.count)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Верхняя панель с прогрессом
                    headerView
                    
                    // Основной контент
                    if let task = currentTask {
                        cardContentView(task: task, geometry: geometry)
                    } else {
                        emptyStateView
                    }
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.05, blue: 0.08),
                            Color(red: 0.08, green: 0.08, blue: 0.12),
                            Color(red: 0.1, green: 0.1, blue: 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .navigationBarHidden(true)
                .preferredColorScheme(.dark)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            // Прогресс бар
            VStack(spacing: 8) {
                HStack {
                    Text("\(currentCardIndex + 1) из \(tasks.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressPercentage, height: 6)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progressPercentage)
                    }
                }
                .frame(height: 6)
            }
            
            // Кнопка завершения
            HStack {
                Spacer()
                
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Завершить")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.3))
    }
    
    // MARK: - Card Content View
    private func cardContentView(task: ModuleTask, geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Главная карточка с переворачиванием
            ZStack {
                // Лицевая сторона (вопрос)
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Вопрос")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.6))
                            .textCase(.uppercase)
                        
                        Text(task.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    // Подсказка о нажатии
                    if !task.description.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "hand.tap")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.4))
                            
                            Text("Нажмите, чтобы увидеть ответ")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height * 0.5)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(0.15),
                                    Color.accentColor.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(0.3),
                                    Color.accentColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .opacity(isFlipped ? 0.0 : 1.0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                
                // Задняя сторона (ответ)
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Ответ")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.6))
                            .textCase(.uppercase)
                        
                        if !task.description.isEmpty {
                            Text(task.description)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("Нет ответа")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    
                    // Подсказка о нажатии обратно
                    VStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text("Нажмите, чтобы вернуться к вопросу")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 20)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height * 0.5)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.15),
                                    Color.green.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.3),
                                    Color.green.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .opacity(isFlipped ? 1.0 : 0.0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Нижние кнопки навигации
            navigationButtons
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            // Кнопка "Назад"
            Button(action: previousCard) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Назад")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .disabled(currentCardIndex == 0)
            .opacity(currentCardIndex == 0 ? 0.4 : 1.0)
            .buttonStyle(PlainButtonStyle())
            
            // Кнопка "Далее"
            Button(action: nextCard) {
                HStack(spacing: 8) {
                    Text("Далее")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .disabled(currentCardIndex == tasks.count - 1)
            .opacity(currentCardIndex == tasks.count - 1 ? 0.4 : 1.0)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80, weight: .ultraLight))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("Нет карточек для изучения")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Добавьте карточки в модуль, чтобы начать изучение")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Navigation Methods
    private func nextCard() {
        guard currentCardIndex < tasks.count - 1 else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentCardIndex += 1
            isFlipped = false // Сбрасываем состояние переворота при переходе к следующей карточке
        }
    }
    
    private func previousCard() {
        guard currentCardIndex > 0 else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentCardIndex -= 1
            isFlipped = false // Сбрасываем состояние переворота при переходе к предыдущей карточке
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