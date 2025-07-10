//
//  CoverFlowView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct CoverFlowView: View {
    let tasks: [ShortCardModel]
    @Binding var currentCardIndex: Int
    @Binding var isFlipped: Bool
    @State private var cardOffset = CGSize.zero
    @State private var isDragging = false
    @State private var isTransitioning = false
    
    private var currentTask: ShortCardModel? {
        guard !tasks.isEmpty, currentCardIndex < tasks.count else { return nil }
        return tasks[currentCardIndex]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.7
            let cardHeight = geometry.size.height * 0.5
            let sideCardWidth = cardWidth * 0.75
            let sideCardHeight = cardHeight * 0.85
            
            ZStack {
                // Левые карточки (стопка предыдущих)
                if currentCardIndex > 0 {
                    ForEach(max(0, currentCardIndex - 3)..<currentCardIndex, id: \.self) { index in
                        let cardIndex = currentCardIndex - index - 1
                        let zOffset = Double(cardIndex * 5)
                        
                        sideStackCardView(
                            task: tasks[index],
                            width: sideCardWidth,
                            height: sideCardHeight,
                            position: .left,
                            stackIndex: cardIndex
                        )
                        .zIndex(-zOffset)
                        .onTapGesture {
                            if currentCardIndex > 0 {
                                performCoverFlowTransition(direction: .right) {
                                    previousCard()
                                }
                            }
                        }
                    }
                }
                
                // Правые карточки (стопка следующих)
                if currentCardIndex < tasks.count - 1 {
                    ForEach(currentCardIndex + 1..<min(tasks.count, currentCardIndex + 4), id: \.self) { index in
                        let cardIndex = index - currentCardIndex - 1
                        let zOffset = Double(cardIndex * 5)
                        
                        sideStackCardView(
                            task: tasks[index],
                            width: sideCardWidth,
                            height: sideCardHeight,
                            position: .right,
                            stackIndex: cardIndex
                        )
                        .zIndex(-zOffset)
                        .onTapGesture {
                            if currentCardIndex < tasks.count - 1 {
                                performCoverFlowTransition(direction: .left) {
                                    nextCard()
                                }
                            }
                        }
                    }
                }
                
                // Центральная карточка (текущая)
                if let currentTask = currentTask {
                    mainCardView(
                        task: currentTask,
                        width: cardWidth,
                        height: cardHeight
                    )
                    .zIndex(1000)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - Main Card View
    private func mainCardView(task: ShortCardModel, width: CGFloat, height: CGFloat) -> some View {
        let rotationAngle = -cardOffset.width / 10  // Инвертируем знак
        let scale = 1.0 - abs(cardOffset.width) / 1000
        
        return ZStack {
            // Лицевая сторона (вопрос)
            VStack(spacing: 16) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Вопрос")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Подсказка о нажатии
                if !task.description.isEmpty && !isDragging {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text("Нажмите, чтобы увидеть ответ")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 16)
                }
                
                // Подсказка о свайпах
                if !isDragging {
                    VStack(spacing: 6) {
                        HStack(spacing: 12) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("Свайп для навигации")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(24)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 20)
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
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            )
            .opacity(isFlipped ? 0.0 : 1.0)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            
            // Задняя сторона (ответ)
            VStack(spacing: 16) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Ответ")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("Нет ответа")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                // Подсказка о нажатии обратно
                if !isDragging {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text("Нажмите, чтобы вернуться к вопросу")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 16)
                }
                
                // Подсказка о свайпах
                if !isDragging {
                    VStack(spacing: 6) {
                        HStack(spacing: 12) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("Свайп для навигации")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(24)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 20)
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
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            )
            .opacity(isFlipped ? 1.0 : 0.0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .offset(x: cardOffset.width, y: 0)
        .scaleEffect(isDragging ? max(0.85, scale) : (isTransitioning ? 0.9 : 1.0))
        .rotation3DEffect(
            .degrees(Double(rotationAngle)),
            axis: (x: 0, y: 1, z: 0)
        )
        .opacity(isTransitioning ? 0.7 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isTransitioning)
        .contentShape(Rectangle())
        .onTapGesture {
            // Проверяем, что не происходит драг
            if !isDragging {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    cardOffset = value.translation
                }
                .onEnded { value in
                    isDragging = false
                    
                    let swipeThreshold: CGFloat = 100
                    let velocity = value.velocity.width
                    
                    if value.translation.width > swipeThreshold || velocity > 500 {
                        // Свайп вправо - предыдущая карточка
                        if currentCardIndex > 0 {
                            performCoverFlowTransition(direction: .right) {
                                previousCard()
                            }
                        } else {
                            // Возвращаем карточку в исходное положение
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                cardOffset = .zero
                            }
                        }
                    } else if value.translation.width < -swipeThreshold || velocity < -500 {
                        // Свайп влево - следующая карточка
                        if currentCardIndex < tasks.count - 1 {
                            performCoverFlowTransition(direction: .left) {
                                nextCard()
                            }
                        } else {
                            // Возвращаем карточку в исходное положение
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                cardOffset = .zero
                            }
                        }
                    } else {
                        // Возвращаем карточку в исходное положение
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            cardOffset = .zero
                        }
                    }
                }
        )
    }
    
    // MARK: - Side Stack Card View (Cover Flow Style)
    private enum CardPosition {
        case left, right
    }
    
    private func sideStackCardView(task: ShortCardModel, width: CGFloat, height: CGFloat, position: CardPosition, stackIndex: Int) -> some View {
        let rotationAngle: Double = position == .left ? 45 : -45
        let baseOffset: CGFloat = position == .left ? -400 : 400
        let xOffset: CGFloat = baseOffset + (position == .left ? -CGFloat(stackIndex * 15) : CGFloat(stackIndex * 15))
        let yOffset: CGFloat = CGFloat(stackIndex * 8)
        let scaleEffect = 1.0 - CGFloat(stackIndex) * 0.1
        let opacityEffect = 1.0 - CGFloat(stackIndex) * 0.3
        
        return VStack {
            // Пустая карточка без текста
        }
        .padding(12)
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.08),
                            Color.accentColor.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.2),
                            Color.accentColor.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(scaleEffect)
        .opacity(opacityEffect)
        .rotation3DEffect(
            .degrees(rotationAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .offset(x: xOffset, y: yOffset)
        .contentShape(Rectangle())
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
    
    // MARK: - Cover Flow Animation
    private enum SwipeDirection {
        case left, right
    }
    
    private func performCoverFlowTransition(direction: SwipeDirection, completion: @escaping () -> Void) {
        // Определяем направления выхода и входа в зависимости от направления свайпа
        // Карточка должна уходить в соответствующую колонку и появляться из противоположной
        let exitOffset: CGFloat
        let enterOffset: CGFloat
        
        switch direction {
        case .left:
            // Свайп влево: карточка уходит в ПРАВУЮ колонку, новая появляется из ЛЕВОЙ колонки
            exitOffset = 400  // Уходит в правую колонку (положительное значение)
            enterOffset = -400  // Появляется из левой колонки (отрицательное значение)
        case .right:
            // Свайп вправо: карточка уходит в ЛЕВУЮ колонку, новая появляется из ПРАВОЙ колонки  
            exitOffset = -400  // Уходит в левую колонку (отрицательное значение)
            enterOffset = 400  // Появляется из правой колонки (положительное значение)
        }
        
        // Начинаем анимацию ухода текущей карточки в соответствующую колонку
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            cardOffset.width = exitOffset
            isTransitioning = true
        }
        
        // Выполняем переход к новой карточке через небольшую задержку
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            completion()
            
            // Устанавливаем новую карточку в противоположной колонке
            cardOffset.width = enterOffset
            
            // Анимируем появление новой карточки из колонки в центр
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cardOffset = .zero
                isTransitioning = false
            }
        }
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
    
    @State var currentIndex = 0
    @State var isFlipped = false
    
    CoverFlowView(
        tasks: sampleTasks,
        currentCardIndex: $currentIndex,
        isFlipped: $isFlipped
    )
} 