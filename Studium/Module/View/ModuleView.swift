//
//  moduleView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct ModuleView: View {
    let module: MainItem
    @StateObject private var viewModel: ModuleViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Инициализатор
    init(module: MainItem) {
        self.module = module
        self._viewModel = StateObject(wrappedValue: ModuleViewModel(module: module))
    }
    
    // Параметры сетки
    private let cardSpacing: CGFloat = 16
    private let horizontalPadding: CGFloat = 40
    private let minCardWidth: CGFloat = 160
    
    // Определяем размер карточки на основе длины текста
    private func cardSize(for task: ShortCardModel) -> CardSize {
        // Карточка-тест: проверяем количество вариантов ответов
        if task.cardType == .test {
            let answers = parseTestAnswers(task.description)
            return answers.count > 4 ? .testLarge : .test
        }
        
        let titleLength = task.title.count
        let descriptionLength = task.description.count
        return (titleLength > 85 || descriptionLength > 85) ? .wide : .regular
    }
    
    // Вспомогательная функция для парсинга ответов теста
    private func parseTestAnswers(_ content: String) -> [TestAnswer] {
        var answers: [TestAnswer] = []
        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            if line.hasPrefix("ПРАВИЛЬНЫЙ: ") {
                let answerText = String(line.dropFirst("ПРАВИЛЬНЫЙ: ".count))
                answers.append(TestAnswer(text: answerText, isCorrect: true))
            } else if line.hasPrefix("НЕПРАВИЛЬНЫЕ: ") {
                let wrongAnswersText = String(line.dropFirst("НЕПРАВИЛЬНЫЕ: ".count))
                let wrongAnswers = wrongAnswersText.components(separatedBy: ", ")
                for wrongAnswer in wrongAnswers {
                    if !wrongAnswer.trimmingCharacters(in: .whitespaces).isEmpty {
                        answers.append(TestAnswer(text: wrongAnswer.trimmingCharacters(in: .whitespaces), isCorrect: false))
                    }
                }
            }
        }

        return answers
    }
    
    // Вычисляем количество колонок для обычных карточек
    private func cardsPerRow(for geometry: GeometryProxy) -> Int {
        let screenWidth = geometry.size.width
        let availableWidth = screenWidth - horizontalPadding
        return max(2, Int((availableWidth + cardSpacing) / (minCardWidth + cardSpacing)))
    }
    
    // Простая сетка с поддержкой тестовых карточек
    private func simpleGridLayout(geometry: GeometryProxy) -> some View {
        let columnsCount = cardsPerRow(for: geometry)
        let cardWidth = (geometry.size.width - horizontalPadding - CGFloat(columnsCount - 1) * cardSpacing) / CGFloat(columnsCount)
        let wideCardWidth = cardWidth * 2 + cardSpacing
        let normalCardHeight: CGFloat = 120
        let testCardHeight: CGFloat = normalCardHeight * 2 + cardSpacing // Высота двух карточек + отступ
        let testLargeCardHeight: CGFloat = normalCardHeight * 3 + cardSpacing * 2 // Высота трех карточек + отступы
        
        let arrangedCards = arrangeCardsInRows(columnsCount: columnsCount)
        
        return VStack(spacing: cardSpacing) {
            ForEach(Array(arrangedCards.enumerated()), id: \.offset) { rowIndex, row in
                createRowView(
                    row: row,
                    cardWidth: cardWidth,
                    wideCardWidth: wideCardWidth,
                    normalCardHeight: normalCardHeight,
                    testCardHeight: testCardHeight,
                    testLargeCardHeight: testLargeCardHeight,
                    columnsCount: columnsCount
                )
            }
        }
    }
    
    // Создаем представление для ряда с учетом тестовых карточек
    private func createRowView(
        row: [ShortCardModel],
        cardWidth: CGFloat,
        wideCardWidth: CGFloat,
        normalCardHeight: CGFloat,
        testCardHeight: CGFloat,
        testLargeCardHeight: CGFloat,
        columnsCount: Int
    ) -> some View {
        let hasTestCard = row.contains { cardSize(for: $0) == .test || cardSize(for: $0) == .testLarge }
        let testCard = row.first { cardSize(for: $0) == .test || cardSize(for: $0) == .testLarge }
        let regularCards = row.filter { cardSize(for: $0) != .test && cardSize(for: $0) != .testLarge } // Включает обычные и широкие карточки
        
        return HStack(alignment: .top, spacing: cardSpacing) {
            // Если есть тестовая карточка, размещаем её первой
            if let testCard = testCard {
                let testCardSize = cardSize(for: testCard)
                let height = testCardSize == .testLarge ? testLargeCardHeight : testCardHeight
                
                createCardView(
                    task: testCard,
                    width: wideCardWidth,
                    height: height
                )
                
                // Размещаем обычные карточки в VStack рядом с тестовой
                if !regularCards.isEmpty {
                    let availableColumns = columnsCount - 2 // Тестовая карточка занимает 2 колонки
                    createRegularCardsStack(
                        cards: regularCards,
                        cardWidth: cardWidth,
                        normalCardHeight: normalCardHeight,
                        availableColumns: availableColumns,
                        testCardHeight: height
                    )
                }
            } else {
                // Обычное размещение без тестовых карточек
                ForEach(row, id: \.id) { task in
                    let size = cardSize(for: task)
                    createCardView(
                        task: task,
                        width: size == .wide ? wideCardWidth : cardWidth,
                        height: normalCardHeight
                    )
                }
            }
            
            Spacer()
        }
    }
    
    // Создаем VStack для обычных карточек рядом с тестовой
    private func createRegularCardsStack(
        cards: [ShortCardModel],
        cardWidth: CGFloat,
        normalCardHeight: CGFloat,
        availableColumns: Int,
        testCardHeight: CGFloat
    ) -> some View {
        let wideCardWidth = cardWidth * 2 + cardSpacing
        
        // Определяем количество уровней на основе высоты тестовой карточки
        let testLargeCardHeight = normalCardHeight * 3 + cardSpacing * 2
        let isTestLarge = testCardHeight >= testLargeCardHeight
        
        return VStack(alignment: .leading, spacing: cardSpacing) {
            if isTestLarge {
                // Размещаем карточки в три уровня для testLarge карточек
                let levelArrangements = arrangeCardsInThreeLevels(cards: cards, availableColumns: availableColumns)
                
                // Верхний уровень
                createLevelView(
                    cards: levelArrangements.topLevel,
                    cardWidth: cardWidth,
                    wideCardWidth: wideCardWidth,
                    normalCardHeight: normalCardHeight,
                    availableColumns: availableColumns,
                    testCardHeight: testCardHeight
                )
                
                // Средний уровень
                createLevelView(
                    cards: levelArrangements.middleLevel,
                    cardWidth: cardWidth,
                    wideCardWidth: wideCardWidth,
                    normalCardHeight: normalCardHeight,
                    availableColumns: availableColumns,
                    testCardHeight: testCardHeight
                )
                
                // Нижний уровень
                createLevelView(
                    cards: levelArrangements.bottomLevel,
                    cardWidth: cardWidth,
                    wideCardWidth: wideCardWidth,
                    normalCardHeight: normalCardHeight,
                    availableColumns: availableColumns,
                    testCardHeight: testCardHeight
                )
            } else {
                // Размещаем карточки в два уровня для обычных test карточек
                let levelArrangements = arrangeCardsInLevels(cards: cards, availableColumns: availableColumns)
                
                // Верхний уровень
                createLevelView(
                    cards: levelArrangements.topLevel,
                    cardWidth: cardWidth,
                    wideCardWidth: wideCardWidth,
                    normalCardHeight: normalCardHeight,
                    availableColumns: availableColumns,
                    testCardHeight: testCardHeight
                )
                
                // Нижний уровень
                createLevelView(
                    cards: levelArrangements.bottomLevel,
                    cardWidth: cardWidth,
                    wideCardWidth: wideCardWidth,
                    normalCardHeight: normalCardHeight,
                    availableColumns: availableColumns,
                    testCardHeight: testCardHeight
                )
            }
        }
        .frame(height: testCardHeight)
    }
    
    // Размещаем карточки по уровням с учетом широких карточек
    private func arrangeCardsInLevels(cards: [ShortCardModel], availableColumns: Int) -> (topLevel: [ShortCardModel], bottomLevel: [ShortCardModel]) {
        var topLevel: [ShortCardModel] = []
        var bottomLevel: [ShortCardModel] = []
        var topLevelWidth = 0
        var bottomLevelWidth = 0
        
        for card in cards {
            let size = cardSize(for: card)
            let cardWidth = (size == .wide || size == .test || size == .testLarge) ? 2 : 1
            
            // Пытаемся разместить в верхнем уровне
            if topLevelWidth + cardWidth <= availableColumns {
                topLevel.append(card)
                topLevelWidth += cardWidth
            }
            // Если не помещается в верхний, пытаемся в нижний
            else if bottomLevelWidth + cardWidth <= availableColumns {
                bottomLevel.append(card)
                bottomLevelWidth += cardWidth
            }
            // Если не помещается ни в один уровень, прерываем (карточка не будет размещена)
            else {
                break
            }
        }
        
        return (topLevel, bottomLevel)
    }
    
    // Размещаем карточки в три уровня для testLarge карточек
    private func arrangeCardsInThreeLevels(cards: [ShortCardModel], availableColumns: Int) -> (topLevel: [ShortCardModel], middleLevel: [ShortCardModel], bottomLevel: [ShortCardModel]) {
        var topLevel: [ShortCardModel] = []
        var middleLevel: [ShortCardModel] = []
        var bottomLevel: [ShortCardModel] = []
        var topLevelWidth = 0
        var middleLevelWidth = 0
        var bottomLevelWidth = 0
        
        for card in cards {
            let size = cardSize(for: card)
            let cardWidth = (size == .wide || size == .test || size == .testLarge) ? 2 : 1
            
            // Пытаемся разместить в верхнем уровне
            if topLevelWidth + cardWidth <= availableColumns {
                topLevel.append(card)
                topLevelWidth += cardWidth
            }
            // Если не помещается в верхний, пытаемся в средний
            else if middleLevelWidth + cardWidth <= availableColumns {
                middleLevel.append(card)
                middleLevelWidth += cardWidth
            }
            // Если не помещается в средний, пытаемся в нижний
            else if bottomLevelWidth + cardWidth <= availableColumns {
                bottomLevel.append(card)
                bottomLevelWidth += cardWidth
            }
            // Если не помещается ни в один уровень, прерываем (карточка не будет размещена)
            else {
                break
            }
        }
        
        return (topLevel, middleLevel, bottomLevel)
    }
    
    // Создаем представление для одного уровня с поддержкой широких карточек
    private func createLevelView(
        cards: [ShortCardModel],
        cardWidth: CGFloat,
        wideCardWidth: CGFloat,
        normalCardHeight: CGFloat,
        availableColumns: Int,
        testCardHeight: CGFloat
    ) -> some View {
        HStack(spacing: cardSpacing) {
            ForEach(cards, id: \.id) { task in
                let size = cardSize(for: task)
                createCardView(
                    task: task,
                    width: (size == .wide || size == .test || size == .testLarge) ? wideCardWidth : cardWidth,
                    height: normalCardHeight
                )
            }
            
            // Добавляем пустое пространство для выравнивания
            let usedWidth = cards.reduce(0) { total, card in
                let size = cardSize(for: card)
                return total + ((size == .wide || size == .test || size == .testLarge) ? 2 : 1)
            }
            
            if usedWidth < availableColumns {
                let remainingWidth = availableColumns - usedWidth
                ForEach(0..<remainingWidth, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: cardWidth, height: normalCardHeight)
                }
            }
        }
    }
    
    // Вспомогательная функция для создания карточки
    private func createCardView(task: ShortCardModel, width: CGFloat, height: CGFloat) -> some View {
        CardView(
            task: task,
            onToggle: {
                viewModel.toggleTaskCompletion(task)
            },
            onDelete: {
                viewModel.deleteTask(task)
            },
            onEdit: {
                viewModel.showEditCard(task)
            },
            isDeleting: viewModel.deletingTaskIds.contains(task.id)
        )
        .frame(width: width, height: height)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.1).combined(with: .opacity)
        ))
    }
    
    // Размещаем карточки в ряды с учетом широких карточек и тестовых карточек
    private func arrangeCardsInRows(columnsCount: Int) -> [[ShortCardModel]] {
        var rows: [[ShortCardModel]] = []
        var rowWidths: [Int] = [] // Отслеживаем занятое пространство в каждом ряду
        var rowHasTestCard: [Bool] = [] // Отслеживаем, есть ли тестовая карточка в ряду
        
        for task in viewModel.tasks {
            let size = cardSize(for: task)
            let cardWidth = size == .wide ? 2 : ((size == .test || size == .testLarge) ? 2 : 1)
            
            // Ищем подходящий ряд для размещения карточки
            var placed = false
            for (index, currentWidth) in rowWidths.enumerated() {
                let canFit = currentWidth + cardWidth <= columnsCount
                
                // Особая логика для тестовых карточек
                if size == .test || size == .testLarge {
                    // Тестовая карточка помещается только если есть место для 2 колонок
                    if canFit && !rowHasTestCard[index] {
                        rows[index].append(task)
                        rowWidths[index] += cardWidth
                        rowHasTestCard[index] = true
                        placed = true
                        break
                    }
                } else {
                    // Обычные карточки
                    if canFit {
                        // Если в ряду уже есть тестовая карточка, можем добавить больше карточек
                        // так как они будут размещены в VStack рядом с тестовой
                        if rowHasTestCard[index] {
                            let regularCards = rows[index].filter { cardSize(for: $0) != .test && cardSize(for: $0) != .testLarge }
                            let availableColumns = columnsCount - 2 // Тестовая карточка занимает 2 колонки
                            
                            // Проверяем тип тестовой карточки в ряду
                            let testCard = rows[index].first { cardSize(for: $0) == .test || cardSize(for: $0) == .testLarge }
                            let isTestLarge = testCard != nil && cardSize(for: testCard!) == .testLarge
                            
                            let testCards = regularCards + [task]
                            
                            if isTestLarge {
                                // Проверяем, поместится ли новая карточка в трехуровневую структуру
                                let levelArrangements = arrangeCardsInThreeLevels(cards: testCards, availableColumns: availableColumns)
                                let totalArrangedCards = levelArrangements.topLevel.count + levelArrangements.middleLevel.count + levelArrangements.bottomLevel.count
                                
                                // Если все карточки помещаются в три уровня, добавляем
                                if totalArrangedCards == testCards.count {
                                    rows[index].append(task)
                                    placed = true
                                    break
                                }
                            } else {
                                // Проверяем, поместится ли новая карточка в двухуровневую структуру
                                let levelArrangements = arrangeCardsInLevels(cards: testCards, availableColumns: availableColumns)
                                let totalArrangedCards = levelArrangements.topLevel.count + levelArrangements.bottomLevel.count
                                
                                // Если все карточки помещаются в два уровня, добавляем
                                if totalArrangedCards == testCards.count {
                                    rows[index].append(task)
                                    placed = true
                                    break
                                }
                            }
                        } else {
                            // Обычное размещение без тестовых карточек
                            rows[index].append(task)
                            rowWidths[index] += cardWidth
                            placed = true
                            break
                        }
                    }
                }
            }
            
            // Если не нашли подходящий ряд, создаем новый
            if !placed {
                rows.append([task])
                rowWidths.append(cardWidth)
                rowHasTestCard.append(size == .test || size == .testLarge)
            }
        }
        
        return rows
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Заголовок с навигацией
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(module.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "tray.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Модуль")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if !viewModel.tasks.isEmpty {
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(viewModel.completedTasks.count)/\(viewModel.tasks.count)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)
                    
                    Spacer()
                }
                .background(
                    Rectangle()
                        .fill(module.gradient)
                        .overlay(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                        )
                        .ignoresSafeArea(.all, edges: .top)
                )
                
                // Контент модуля
                if viewModel.tasks.isEmpty {
                    // Пустое состояние
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .opacity(0.6)
                        
                        VStack(spacing: 8) {
                            Text("Пустой модуль")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Добавьте задачи или материалы для изучения")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                    // Простая сетка карточек
                    GeometryReader { geometry in
                        ScrollView {
                            simpleGridLayout(geometry: geometry)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 100) // Отступ для кнопок
                        }
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.tasks.count)
                    }
                }
            }
            .background(Color.graphite)
            
            // Нижняя панель с кнопками
            VStack {
                Spacer()
                
                DockBar(
                    hasCards: !viewModel.tasks.isEmpty,
                    onStudyCards: {
                        viewModel.startStudyingCards()
                    },
                    onAddCard: {
                        viewModel.toggleAddCardMenu()
                    },
                    showingAddMenu: viewModel.showingAddCardMenu
                )
            }
            
            // Меню добавления карточек
            if viewModel.showingAddCardMenu {
                AddCardMenuView(
                    onAddShortCard: {
                        viewModel.showAddShortCard()
                    },
                    onAddRegularCard: {
                        viewModel.showAddRegularCard()
                    },
                    onAddTestCard: {
                        viewModel.showAddTestCard()
                    }
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.showingAddCardMenu)
            }
        }
        .onTapGesture {
            if viewModel.showingAddCardMenu {
                viewModel.hideAddCardMenu()
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingAddShortCard) {
            ShortCardView(cardType: .short) { title, content, isBothSides in
                viewModel.addCard(type: .short, title: title, content: content, isBothSides: isBothSides)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingAddRegularCard) {
            ShortCardView(cardType: .regular) { title, content, isBothSides in
                viewModel.addCard(type: .regular, title: title, content: content, isBothSides: isBothSides)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingAddTestCard) {
            AddTestCardView { title, content, isBothSides in
                viewModel.addCard(type: .test, title: title, content: content, isBothSides: isBothSides)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingEditCardType) {
            if let editingCard = viewModel.editingCard {
                if editingCard.cardType == .test {
                    EditTestCardView(card: editingCard) { title, content, isBothSides in
                        viewModel.editCard(cardId: editingCard.id, type: editingCard.cardType, title: title, content: content, isBothSides: isBothSides)
                    }
                } else {
                    EditShortCardView(card: editingCard) { title, content, isBothSides in
                        viewModel.editCard(cardId: editingCard.id, type: editingCard.cardType, title: title, content: content, isBothSides: isBothSides)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingStudyCards) {
            StudyModeView(tasks: viewModel.tasks)
        }
        .navigationBarHidden(true)
    }
}


#Preview {
    let sampleModule = MainItem(
        name: "Swift Programming",
        type: .module,
        gradient: LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        createdAt: Date(),
        parentId: nil
    )
    
    ModuleView(module: sampleModule)
}


