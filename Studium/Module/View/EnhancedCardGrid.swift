import SwiftUI

// MARK: - Enhanced Card Size
enum EnhancedCardSize {
    case compact
    case regular
    case wide
    case extraWide
    case test
    case testLarge
    
    var columnSpan: Int {
        switch self {
        case .compact: return 1
        case .regular: return 1
        case .wide: return 2
        case .extraWide: return 3
        case .test: return 2
        case .testLarge: return 2
        }
    }
    
    var priority: Int {
        switch self {
        case .testLarge: return 100
        case .test: return 90
        case .extraWide: return 80
        case .wide: return 70
        case .regular: return 60
        case .compact: return 50
        }
    }
    
    var isTest: Bool {
        return self == .test || self == .testLarge
    }
    
    func width(for gridConfig: GridConfiguration) -> CGFloat {
        switch self {
        case .compact: return gridConfig.cardWidth * 0.8
        case .regular: return gridConfig.cardWidth
        case .wide: return gridConfig.wideCardWidth
        case .extraWide: return gridConfig.extraWideCardWidth
        case .test: return gridConfig.wideCardWidth
        case .testLarge: return gridConfig.wideCardWidth
        }
    }
    
    func height(for gridConfig: GridConfiguration) -> CGFloat {
        switch self {
        case .compact: return gridConfig.compactCardHeight
        case .regular: return gridConfig.regularCardHeight
        case .wide: return gridConfig.wideCardHeight
        case .extraWide: return gridConfig.wideCardHeight
        case .test: return gridConfig.testCardHeight
        case .testLarge: return gridConfig.testLargeCardHeight
        }
    }
}

// MARK: - Grid Configuration
struct GridConfiguration {
    let columns: Int
    let cardWidth: CGFloat
    let wideCardWidth: CGFloat
    let extraWideCardWidth: CGFloat
    let compactCardHeight: CGFloat
    let regularCardHeight: CGFloat
    let wideCardHeight: CGFloat
    let testCardHeight: CGFloat
    let testLargeCardHeight: CGFloat
}

// MARK: - Card Group
struct CardGroup {
    let title: String
    let cards: [ShortCardModel]
    let priority: Int
    let showHeader: Bool
    let isCompleted: Bool
    
    init(title: String, cards: [ShortCardModel], priority: Int, showHeader: Bool, isCompleted: Bool = false) {
        self.title = title
        self.cards = cards
        self.priority = priority
        self.showHeader = showHeader
        self.isCompleted = isCompleted
    }
}

// MARK: - Enhanced Card Grid
struct EnhancedCardGrid: View {
    let tasks: [ShortCardModel]
    let viewModel: ModuleViewModel
    
    // MARK: - Grid Parameters
    private let cardSpacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 20
    private let minCardWidth: CGFloat = 140
    private let maxCardWidth: CGFloat = 200
    private let baseCardHeight: CGFloat = 110
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                enhancedGridLayoutWithGrouping(geometry: geometry)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Отступ для кнопок
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // MARK: - Smart Card Sizing
    private func smartCardSize(for task: ShortCardModel) -> EnhancedCardSize {
        if task.cardType == .test {
            let answers = parseTestAnswers(task.description)
            return answers.count > 4 ? .testLarge : .test
        }
        
        let titleLength = task.title.count
        let descriptionLength = task.description.count
        let totalLength = titleLength + descriptionLength
        
        // Более умная логика определения размера
        if totalLength > 200 {
            return .extraWide
        } else if totalLength > 120 || titleLength > 60 || descriptionLength > 80 {
            return .wide
        } else if totalLength < 30 {
            return .compact
        } else {
            return .regular
        }
    }
    
    // MARK: - Smart Card Grouping
    private func groupCards() -> [CardGroup] {
        var groups: [CardGroup] = []
        
        // Группируем карточки по статусу и типу
        let activeTasks = tasks.filter { !$0.isCompleted }
        let completedTasks = tasks.filter { $0.isCompleted }
        
        // Активные карточки
        if !activeTasks.isEmpty {
            let testCards = activeTasks.filter { $0.cardType == .test }
            let regularCards = activeTasks.filter { $0.cardType != .test }
            
            // Приоритетная группа: Тестовые карточки
            if !testCards.isEmpty {
                groups.append(CardGroup(
                    title: "Тесты",
                    cards: testCards,
                    priority: 100,
                    showHeader: testCards.count > 1
                ))
            }
            
            // Основная группа: Обычные карточки
            if !regularCards.isEmpty {
                groups.append(CardGroup(
                    title: "Материалы",
                    cards: regularCards,
                    priority: 80,
                    showHeader: false
                ))
            }
        }
        
        // Завершенные карточки (если есть)
        if !completedTasks.isEmpty {
            groups.append(CardGroup(
                title: "Завершено",
                cards: completedTasks,
                priority: 10,
                showHeader: true,
                isCompleted: true
            ))
        }
        
        return groups.sorted { $0.priority > $1.priority }
    }
    
    // MARK: - Dynamic Grid Calculation
    private func calculateOptimalGrid(for geometry: GeometryProxy) -> GridConfiguration {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        let availableWidth = screenWidth - horizontalPadding * 2
        let isLandscape = screenWidth > screenHeight
        
        // Адаптивные параметры для разных размеров экрана
        let adaptiveMinCardWidth: CGFloat = {
            if screenWidth < 400 { return 120 } // Компактные экраны
            else if screenWidth < 800 { return minCardWidth } // Обычные экраны
            else { return 180 } // Широкие экраны
        }()
        
        let adaptiveMaxCardWidth: CGFloat = {
            if screenWidth < 400 { return 160 }
            else if screenWidth < 800 { return maxCardWidth }
            else { return 240 }
        }()
        
        let adaptiveCardSpacing: CGFloat = {
            if screenWidth < 400 { return 8 }
            else if screenWidth < 800 { return cardSpacing }
            else { return 16 }
        }()
        
        // Определяем оптимальное количество колонок с учетом ориентации
        let baseColumns = max(2, Int(availableWidth / (adaptiveMinCardWidth + adaptiveCardSpacing)))
        let maxColumns = isLandscape ? 8 : 6
        let actualColumns = min(baseColumns, maxColumns)
        
        // Рассчитываем динамическую ширину карточки
        let cardWidth = (availableWidth - CGFloat(actualColumns - 1) * adaptiveCardSpacing) / CGFloat(actualColumns)
        let clampedCardWidth = min(max(cardWidth, adaptiveMinCardWidth), adaptiveMaxCardWidth)
        
        // Адаптивные высоты карточек
        let heightMultiplier: CGFloat = screenWidth < 400 ? 0.9 : 1.0
        let adaptiveBaseHeight = baseCardHeight * heightMultiplier
        
        return GridConfiguration(
            columns: actualColumns,
            cardWidth: clampedCardWidth,
            wideCardWidth: clampedCardWidth * 2 + adaptiveCardSpacing,
            extraWideCardWidth: clampedCardWidth * 3 + adaptiveCardSpacing * 2,
            compactCardHeight: adaptiveBaseHeight * 0.8,
            regularCardHeight: adaptiveBaseHeight,
            wideCardHeight: adaptiveBaseHeight * 1.2,
            testCardHeight: adaptiveBaseHeight * 2 + adaptiveCardSpacing,
            testLargeCardHeight: adaptiveBaseHeight * 3 + adaptiveCardSpacing * 2
        )
    }
    
    // MARK: - Enhanced Grid Layout with Grouping
    private func enhancedGridLayoutWithGrouping(geometry: GeometryProxy) -> some View {
        let gridConfig = calculateOptimalGrid(for: geometry)
        let cardGroups = groupCards()
        
        return VStack(spacing: cardSpacing * 2) {
            ForEach(Array(cardGroups.enumerated()), id: \.offset) { groupIndex, group in
                VStack(spacing: cardSpacing) {
                    // Заголовок группы
                    if group.showHeader {
                        createGroupHeader(for: group)
                            .transition(.asymmetric(
                                insertion: AnyTransition.slide.combined(with: AnyTransition.opacity),
                                removal: AnyTransition.slide.combined(with: AnyTransition.opacity)
                            ))
                    }
                    
                    // Карточки группы
                    let arrangedRows = optimizedArrangeCardsInRows(
                        cards: group.cards,
                        gridConfig: gridConfig
                    )
                    
                    ForEach(Array(arrangedRows.enumerated()), id: \.offset) { rowIndex, row in
                        createEnhancedRowView(
                            row: row,
                            gridConfig: gridConfig,
                            rowIndex: rowIndex,
                            isCompleted: group.isCompleted
                        )
                        .transition(.asymmetric(
                            insertion: AnyTransition.move(edge: .bottom)
                                .combined(with: AnyTransition.opacity)
                                .combined(with: AnyTransition.scale(scale: 0.9)),
                            removal: AnyTransition.move(edge: .top)
                                .combined(with: AnyTransition.opacity)
                                .combined(with: AnyTransition.scale(scale: 0.8))
                        ))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(rowIndex) * 0.05), value: gridConfig.columns)
                    }
                }
                .opacity(group.isCompleted ? 0.6 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: group.cards.count)
                .transition(.asymmetric(
                    insertion: AnyTransition.move(edge: .bottom).combined(with: AnyTransition.opacity),
                    removal: AnyTransition.move(edge: .top).combined(with: AnyTransition.opacity)
                ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cardGroups.count)
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: gridConfig.columns)
        .onAppear {
            // Стартовая анимация для всей сетки
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                // Триггер для начальной анимации
            }
        }
    }
    
    // MARK: - Group Header
    private func createGroupHeader(for group: CardGroup) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: group.isCompleted ? "checkmark.circle.fill" : "folder.fill")
                    .font(.caption)
                    .foregroundColor(group.isCompleted ? .green : .blue)
                
                Text(group.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("(\(group.cards.count))")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
            )
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Enhanced Row Creation
    private func createEnhancedRowView(
        row: [ShortCardModel],
        gridConfig: GridConfiguration,
        rowIndex: Int,
        isCompleted: Bool = false
    ) -> some View {
        let hasTestCard = row.contains { smartCardSize(for: $0).isTest }
        let testCard = row.first { smartCardSize(for: $0).isTest }
        let regularCards = row.filter { !smartCardSize(for: $0).isTest }
        
        return HStack(alignment: .top, spacing: cardSpacing) {
            if let testCard = testCard {
                // Размещение тестовой карточки
                let testCardSize = smartCardSize(for: testCard)
                let height = testCardSize == .testLarge ? gridConfig.testLargeCardHeight : gridConfig.testCardHeight
                
                createEnhancedCardView(
                    task: testCard,
                    width: gridConfig.wideCardWidth,
                    height: height,
                    gridConfig: gridConfig
                )
                
                // Размещение обычных карточек рядом с тестовой
                if !regularCards.isEmpty {
                    createSmartRegularCardsStack(
                        cards: regularCards,
                        gridConfig: gridConfig,
                        testCardHeight: height
                    )
                }
            } else {
                // Обычное размещение без тестовых карточек
                ForEach(row, id: \.id) { task in
                    let cardSize = smartCardSize(for: task)
                    let width = cardSize.width(for: gridConfig)
                    let height = cardSize.height(for: gridConfig)
                    
                    createEnhancedCardView(
                        task: task,
                        width: width,
                        height: height,
                        gridConfig: gridConfig
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .scaleEffect(isCompleted ? 0.95 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCompleted)
    }
    
    // MARK: - Smart Regular Cards Stack
    private func createSmartRegularCardsStack(
        cards: [ShortCardModel],
        gridConfig: GridConfiguration,
        testCardHeight: CGFloat
    ) -> some View {
        let availableColumns = gridConfig.columns - 2
        let isTestLarge = testCardHeight >= gridConfig.testLargeCardHeight
        
        return VStack(alignment: .leading, spacing: cardSpacing) {
            if isTestLarge {
                let arrangements = arrangeCardsInLevels(cards: cards, availableColumns: availableColumns, levels: 3)
                
                ForEach(Array(arrangements.enumerated()), id: \.offset) { levelIndex, levelCards in
                    createSmartLevelView(
                        cards: levelCards,
                        gridConfig: gridConfig,
                        availableColumns: availableColumns
                    )
                }
            } else {
                let arrangements = arrangeCardsInLevels(cards: cards, availableColumns: availableColumns, levels: 2)
                
                ForEach(Array(arrangements.enumerated()), id: \.offset) { levelIndex, levelCards in
                    createSmartLevelView(
                        cards: levelCards,
                        gridConfig: gridConfig,
                        availableColumns: availableColumns
                    )
                }
            }
        }
        .frame(height: testCardHeight)
    }
    
    // MARK: - Smart Level View
    private func createSmartLevelView(
        cards: [ShortCardModel],
        gridConfig: GridConfiguration,
        availableColumns: Int
    ) -> some View {
        HStack(spacing: cardSpacing) {
            ForEach(cards, id: \.id) { task in
                let cardSize = smartCardSize(for: task)
                let width = cardSize.width(for: gridConfig)
                let height = cardSize.height(for: gridConfig)
                
                createEnhancedCardView(
                    task: task,
                    width: width,
                    height: height,
                    gridConfig: gridConfig
                )
            }
            
            Spacer()
        }
    }
    
    // MARK: - Enhanced Card View
    private func createEnhancedCardView(
        task: ShortCardModel,
        width: CGFloat,
        height: CGFloat,
        gridConfig: GridConfiguration
    ) -> some View {
        let cardSize = smartCardSize(for: task)
        let isCompact = cardSize == .compact
        let isWide = cardSize == .wide || cardSize == .extraWide
        let isTest = cardSize.isTest
        
        return CardView(
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
        .scaleEffect(isCompact ? 0.95 : 1.0)
        .overlay(
            // Визуальные индикаторы для разных типов карточек
            Group {
                if isTest {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(4)
                        }
                        Spacer()
                    }
                }
                
                if isWide {
                    VStack {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                                .padding(4)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
                if task.isCompleted {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.7))
                                .padding(6)
                        }
                    }
                }
            }
        )
        .shadow(
            color: .black.opacity(isTest ? 0.15 : 0.08),
            radius: isTest ? 4 : 2,
            x: 0,
            y: isTest ? 2 : 1
        )
        .transition(.asymmetric(
            insertion: AnyTransition.scale(scale: 0.8)
                .combined(with: AnyTransition.opacity)
                .combined(with: AnyTransition.slide),
            removal: AnyTransition.scale(scale: 0.1)
                .combined(with: AnyTransition.opacity)
        ))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: task.isCompleted)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.deletingTaskIds.contains(task.id))
    }
    
    // MARK: - Optimized Card Arrangement
    private func optimizedArrangeCardsInRows(cards: [ShortCardModel], gridConfig: GridConfiguration) -> [[ShortCardModel]] {
        var rows: [[ShortCardModel]] = []
        var currentRow: [ShortCardModel] = []
        var currentRowWidth = 0
        
        for task in cards {
            let cardSize = smartCardSize(for: task)
            let cardWidth = cardSize.columnSpan
            
            // Проверяем, помещается ли карточка в текущий ряд
            if currentRowWidth + cardWidth <= gridConfig.columns {
                currentRow.append(task)
                currentRowWidth += cardWidth
            } else {
                // Сохраняем текущий ряд и начинаем новый
                if !currentRow.isEmpty {
                    rows.append(currentRow)
                }
                currentRow = [task]
                currentRowWidth = cardWidth
            }
        }
        
        // Добавляем последний ряд
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return optimizeRowArrangement(rows: rows, gridConfig: gridConfig)
    }
    
    // MARK: - Row Optimization
    private func optimizeRowArrangement(rows: [[ShortCardModel]], gridConfig: GridConfiguration) -> [[ShortCardModel]] {
        var optimizedRows: [[ShortCardModel]] = []
        
        for row in rows {
            let hasTestCard = row.contains { smartCardSize(for: $0).isTest }
            
            if hasTestCard {
                optimizedRows.append(row)
            } else {
                // Пытаемся оптимизировать обычные ряды
                let optimizedRow = optimizeRegularRow(row: row, gridConfig: gridConfig)
                optimizedRows.append(optimizedRow)
            }
        }
        
        return optimizedRows
    }
    
    // MARK: - Regular Row Optimization
    private func optimizeRegularRow(row: [ShortCardModel], gridConfig: GridConfiguration) -> [ShortCardModel] {
        // Сортируем карточки по приоритету размещения
        let sortedCards = row.sorted { card1, card2 in
            let size1 = smartCardSize(for: card1)
            let size2 = smartCardSize(for: card2)
            
            // Приоритет: тестовые -> широкие -> обычные -> компактные
            return size1.priority > size2.priority
        }
        
        return sortedCards
    }
    
    // MARK: - Multi-Level Card Arrangement
    private func arrangeCardsInLevels(cards: [ShortCardModel], availableColumns: Int, levels: Int) -> [[ShortCardModel]] {
        var levelArrangements: [[ShortCardModel]] = Array(repeating: [], count: levels)
        var levelWidths: [Int] = Array(repeating: 0, count: levels)
        
        for card in cards {
            let cardSize = smartCardSize(for: card)
            let cardWidth = cardSize.columnSpan
            
            // Находим подходящий уровень
            for levelIndex in 0..<levels {
                if levelWidths[levelIndex] + cardWidth <= availableColumns {
                    levelArrangements[levelIndex].append(card)
                    levelWidths[levelIndex] += cardWidth
                    break
                }
            }
        }
        
        return levelArrangements
    }
    
    // MARK: - Helper Functions
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
}
