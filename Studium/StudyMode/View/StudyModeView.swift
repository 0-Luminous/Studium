//
//  StudyModeView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct StudyModeView: View {
    let tasks: [ShortCardModel]
    @Environment(\.dismiss) private var dismiss
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    
    private var currentTask: ShortCardModel? {
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
    private func cardContentView(task: ShortCardModel, geometry: GeometryProxy) -> some View {
        return VStack(spacing: 0) {
            Spacer()
            
            // Cover Flow карусель
            CoverFlowView(
                tasks: tasks,
                currentCardIndex: $currentCardIndex,
                isFlipped: $isFlipped
            )
            
            Spacer()
        }
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
}

#Preview {
    let sampleTasks = [
        ShortCardModel(
            title: "Что такое Swift?", 
            description: "Swift - это мощный и интуитивно понятный язык программирования для iOS, macOS, watchOS и tvOS.",
            isCompleted: false,
            cardType: .regular,
            isBothSides: true,
            moduleId: UUID()
        ),
        ShortCardModel(
            title: "Что такое Optional?", 
            description: "Optional - это тип данных, который может содержать значение или nil.",
            isCompleted: false,
            cardType: .regular,
            isBothSides: true,
            moduleId: UUID()
        )
    ]
    
    StudyModeView(tasks: sampleTasks)
} 
