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
    @State private var nextCardIndex: Int? = nil
    @State private var nextCardOffset = CGSize.zero
    @State private var nextCardRotation: Double = 0
    @State private var nextCardScale: CGFloat = 0.75
    
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
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        .animation(.easeInOut(duration: 0.25), value: currentCardIndex)
                        .onTapGesture {
                            if currentCardIndex > 0 {
                                let defaultSpeed = AnimationSpeed(
                                    transitionAnimation: .spring(response: 0.6, dampingFraction: 0.85),
                                    returnAnimation: .spring(response: 0.6, dampingFraction: 0.85),
                                    delayDuration: 0.6
                                )
                                performCoverFlowTransition(direction: .right, animationSpeed: defaultSpeed) {
                                    previousCard(animationSpeed: defaultSpeed)
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
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        .animation(.easeInOut(duration: 0.25), value: currentCardIndex)
                        .onTapGesture {
                            if currentCardIndex < tasks.count - 1 {
                                let defaultSpeed = AnimationSpeed(
                                    transitionAnimation: .spring(response: 0.6, dampingFraction: 0.85),
                                    returnAnimation: .spring(response: 0.6, dampingFraction: 0.85),
                                    delayDuration: 0.6
                                )
                                performCoverFlowTransition(direction: .left, animationSpeed: defaultSpeed) {
                                    nextCard(animationSpeed: defaultSpeed)
                                }
                            }
                        }
                    }
                }
                
                // Следующая карточка (анимируется во время перехода)
                if let nextIndex = nextCardIndex, nextIndex < tasks.count {
                    let nextTask = tasks[nextIndex]
                    nextCardView(
                        task: nextTask,
                        width: cardWidth,
                        height: cardHeight
                    )
                    .zIndex(999)
                }
                
                // Центральная карточка (текущая) - скрываем во время перехода
                if let currentTask = currentTask, !isTransitioning {
                    // Определяем тип карточки и отображаем соответствующий вид
                    if currentTask.cardType == .test {
                        StudyTestCardView(
                            task: currentTask,
                            width: cardWidth,
                            height: cardHeight * 1.3,
                            cardOffset: $cardOffset,
                            isDragging: $isDragging,
                            currentCardIndex: currentCardIndex,
                            isTransitioning: isTransitioning,
                            onDragChanged: { value in
                                withAnimation(.interpolatingSpring(stiffness: 400, damping: 40)) {
                                    isDragging = true
                                    cardOffset = value.translation
                                }
                            },
                            onDragEnded: { value in
                                isDragging = false
                                
                                let swipeThreshold: CGFloat = 50
                                let velocity = value.velocity.width
                                let absVelocity = abs(velocity)
                                
                                // Адаптивная анимация в зависимости от скорости
                                let animationSpeed = getAdaptiveAnimationSpeed(velocity: absVelocity)
                                
                                if value.translation.width > swipeThreshold || velocity > 300 {
                                    // Свайп вправо - предыдущая карточка
                                    if currentCardIndex > 0 {
                                        performCoverFlowTransition(direction: .right, animationSpeed: animationSpeed) {
                                            previousCard(animationSpeed: animationSpeed)
                                        }
                                    } else {
                                        // Если нет предыдущей карточки, возвращаем текущую в центр
                                        withAnimation(animationSpeed.returnAnimation) {
                                            cardOffset = .zero
                                        }
                                    }
                                } else if value.translation.width < -swipeThreshold || velocity < -300 {
                                    // Свайп влево - следующая карточка
                                    if currentCardIndex < tasks.count - 1 {
                                        performCoverFlowTransition(direction: .left, animationSpeed: animationSpeed) {
                                            nextCard(animationSpeed: animationSpeed)
                                        }
                                    } else {
                                        // Если нет следующей карточки, возвращаем текущую в центр
                                        withAnimation(animationSpeed.returnAnimation) {
                                            cardOffset = .zero
                                        }
                                    }
                                } else {
                                    // Если свайп слишком слабый, возвращаем карточку в центр
                                    withAnimation(animationSpeed.returnAnimation) {
                                        cardOffset = .zero
                                    }
                                }
                            }
                        )
                        .zIndex(1000)
                    } else {
                        StudyCardView(
                            task: currentTask,
                            width: cardWidth,
                            height: cardHeight,
                            isFlipped: $isFlipped,
                            cardOffset: $cardOffset,
                            isDragging: $isDragging,
                            currentCardIndex: currentCardIndex,
                            isTransitioning: isTransitioning,
                            onTap: {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                                    isFlipped.toggle()
                                }
                            },
                            onDragChanged: { value in
                                withAnimation(.interpolatingSpring(stiffness: 400, damping: 40)) {
                                    isDragging = true
                                    cardOffset = value.translation
                                }
                            },
                            onDragEnded: { value in
                                isDragging = false
                                
                                let swipeThreshold: CGFloat = 50
                                let velocity = value.velocity.width
                                let absVelocity = abs(velocity)
                                
                                // Адаптивная анимация в зависимости от скорости
                                let animationSpeed = getAdaptiveAnimationSpeed(velocity: absVelocity)
                                
                                if value.translation.width > swipeThreshold || velocity > 300 {
                                    // Свайп вправо - предыдущая карточка
                                    if currentCardIndex > 0 {
                                        performCoverFlowTransition(direction: .right, animationSpeed: animationSpeed) {
                                            previousCard(animationSpeed: animationSpeed)
                                        }
                                    } else {
                                        // Если нет предыдущей карточки, возвращаем текущую в центр
                                        withAnimation(animationSpeed.returnAnimation) {
                                            cardOffset = .zero
                                        }
                                    }
                                } else if value.translation.width < -swipeThreshold || velocity < -300 {
                                    // Свайп влево - следующая карточка
                                    if currentCardIndex < tasks.count - 1 {
                                        performCoverFlowTransition(direction: .left, animationSpeed: animationSpeed) {
                                            nextCard(animationSpeed: animationSpeed)
                                        }
                                    } else {
                                        // Если нет следующей карточки, возвращаем текущую в центр
                                        withAnimation(animationSpeed.returnAnimation) {
                                            cardOffset = .zero
                                        }
                                    }
                                } else {
                                    // Если свайп слишком слабый, возвращаем карточку в центр
                                    withAnimation(animationSpeed.returnAnimation) {
                                        cardOffset = .zero
                                    }
                                }
                            }
                        )
                        .zIndex(1000)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - Next Card View (for transition animation)
    private func nextCardView(task: ShortCardModel, width: CGFloat, height: CGFloat) -> some View {
        @State var tempIsFlipped = false
        @State var tempCardOffset = CGSize.zero
        @State var tempIsDragging = false
        
        return Group {
            if task.cardType == .test {
                StudyTestCardView(
                    task: task,
                    width: width,
                    height: height * 1.3,
                    cardOffset: $tempCardOffset,
                    isDragging: $tempIsDragging,
                    currentCardIndex: -1, // Не показываем подсказки для следующей карточки
                    isTransitioning: false,
                    onDragChanged: { _ in },
                    onDragEnded: { _ in }
                )
            } else {
                StudyCardView(
                    task: task,
                    width: width,
                    height: height,
                    isFlipped: $tempIsFlipped,
                    cardOffset: $tempCardOffset,
                    isDragging: $tempIsDragging,
                    currentCardIndex: -1, // Не показываем подсказки для следующей карточки
                    isTransitioning: false,
                    onTap: { },
                    onDragChanged: { _ in },
                    onDragEnded: { _ in }
                )
            }
        }
        .offset(nextCardOffset)
        .scaleEffect(nextCardScale)
        .rotation3DEffect(
            .degrees(nextCardRotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .contentShape(Rectangle())
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
    
    // MARK: - Animation Speed Management
    private struct AnimationSpeed {
        let transitionAnimation: Animation
        let returnAnimation: Animation
        let delayDuration: Double
    }
    
    private func getAdaptiveAnimationSpeed(velocity: CGFloat) -> AnimationSpeed {
        // Категоризируем скорость свайпа
        switch velocity {
        case 0..<500:
            // Медленный свайп - стандартные плавные анимации
            return AnimationSpeed(
                transitionAnimation: .spring(response: 0.5, dampingFraction: 0.85),
                returnAnimation: .spring(response: 0.6, dampingFraction: 0.85),
                delayDuration: 0.5
            )
        case 500..<1000:
            // Средний свайп - немного быстрее
            return AnimationSpeed(
                transitionAnimation: .spring(response: 0.4, dampingFraction: 0.8),
                returnAnimation: .spring(response: 0.4, dampingFraction: 0.8),
                delayDuration: 0.4
            )
        case 1000..<2000:
            // Быстрый свайп - быстрые анимации
            return AnimationSpeed(
                transitionAnimation: .spring(response: 0.3, dampingFraction: 0.75),
                returnAnimation: .spring(response: 0.3, dampingFraction: 0.75),
                delayDuration: 0.3
            )
        default:
            // Очень быстрый свайп - максимально быстрые анимации
            return AnimationSpeed(
                transitionAnimation: .spring(response: 0.2, dampingFraction: 0.7),
                returnAnimation: .spring(response: 0.2, dampingFraction: 0.7),
                delayDuration: 0.2
            )
        }
    }

    // MARK: - Navigation Methods
    private func nextCard(animationSpeed: AnimationSpeed = AnimationSpeed(
        transitionAnimation: .spring(response: 0.6, dampingFraction: 0.85),
        returnAnimation: .spring(response: 0.6, dampingFraction: 0.85),
        delayDuration: 0.6
    )) {
        guard currentCardIndex < tasks.count - 1 else { return }
        
        withAnimation(animationSpeed.transitionAnimation) {
            currentCardIndex += 1
            isFlipped = false
        }
    }
    
    private func previousCard(animationSpeed: AnimationSpeed = AnimationSpeed(
        transitionAnimation: .spring(response: 0.6, dampingFraction: 0.85),
        returnAnimation: .spring(response: 0.6, dampingFraction: 0.85),
        delayDuration: 0.6
    )) {
        guard currentCardIndex > 0 else { return }
        
        withAnimation(animationSpeed.transitionAnimation) {
            currentCardIndex -= 1
            isFlipped = false
        }
    }

    // MARK: - Cover Flow Animation
    private enum SwipeDirection {
        case left, right
    }
    
    private func performCoverFlowTransition(
        direction: SwipeDirection, 
        animationSpeed: AnimationSpeed = AnimationSpeed(
            transitionAnimation: .spring(response: 0.7, dampingFraction: 0.85),
            returnAnimation: .spring(response: 0.6, dampingFraction: 0.85),
            delayDuration: 0.7
        ),
        completion: @escaping () -> Void
    ) {
        // Определяем направления выхода и входа в зависимости от направления свайпа
        let exitOffset: CGFloat
        let enterOffset: CGFloat
        let enterRotation: Double
        let enterScale: CGFloat
        let targetCardIndex: Int
        
        switch direction {
        case .left:
            // Свайп влево: следующая карточка (новая появляется справа)
            exitOffset = -600  // Текущая карточка полностью уходит влево за экран
            enterOffset = 600  // Новая карточка появляется справа за экраном
            enterRotation = -45  // Поворот как в правой колонке
            enterScale = 0.75  // Масштаб как в колонке
            targetCardIndex = currentCardIndex + 1
        case .right:
            // Свайп вправо: предыдущая карточка (новая появляется слева)
            exitOffset = 600  // Текущая карточка полностью уходит вправо за экран
            enterOffset = -600  // Новая карточка появляется слева за экраном
            enterRotation = 45  // Поворот как в левой колонке
            enterScale = 0.75  // Масштаб как в колонке
            targetCardIndex = currentCardIndex - 1
        }
        
        // Шаг 1: Анимируем исчезновение текущей карточки
        // Карточка продолжает движение в том же направлении и полностью выходит за экран
        withAnimation(animationSpeed.transitionAnimation) {
            cardOffset.width = exitOffset
            isTransitioning = true
        }
        
        // Шаг 2: Одновременно с началом исчезновения показываем новую карточку
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Устанавливаем новую карточку в начальную позицию (за кадром)
            nextCardIndex = targetCardIndex
            nextCardOffset = CGSize(width: enterOffset, height: 0)
            nextCardRotation = enterRotation
            nextCardScale = enterScale
            
            // Шаг 3: Анимируем появление новой карточки
            withAnimation(animationSpeed.transitionAnimation) {
                // Новая карточка движется к центру
                nextCardOffset = .zero
                nextCardRotation = 0
                nextCardScale = 1.0
            }
            
            // Шаг 4: Завершаем переход после появления новой карточки
            DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.delayDuration) {
                completion()
                
                // Сбрасываем состояния
                isTransitioning = false
                cardOffset = .zero
                nextCardIndex = nil
                nextCardOffset = .zero
                nextCardRotation = 0
                nextCardScale = 0.75
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
        ),
        ShortCardModel(
            title: "Какой из этих типов данных является правильным в Swift?",
            description: "ПРАВИЛЬНЫЙ: String\nНЕПРАВИЛЬНЫЕ: string, STRING, Str\nПОЯСНЕНИЕ: В Swift типы данных начинаются с заглавной буквы, поэтому правильный тип для строки - String.",
            isCompleted: false,
            cardType: .test,
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