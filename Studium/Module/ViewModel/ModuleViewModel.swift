import SwiftUI
import Foundation

class ModuleViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tasks: [ShortCardModel] = [] // Задачи модуля
    @Published var showingAddCardType = false // Убираем showingAddOptions
    @Published var showingStudyCards = false // Для отображения режима изучения
    @Published var deletingTaskIds: Set<UUID> = [] // Карточки в процессе удаления
    @Published var showingEditCardType = false // Для редактирования карточки
    @Published var editingCard: ShortCardModel? = nil // Карточка для редактирования
    
    // MARK: - Properties
    let module: MainItem
    private let cardRepository: CardRepository
    
    // MARK: - Initialization
    init(module: MainItem, cardRepository: CardRepository = CardRepository()) {
        self.module = module
        self.cardRepository = cardRepository
        loadTasks()
    }
    
    // MARK: - Computed Properties
    var completedTasks: [ShortCardModel] {
        tasks.filter { $0.isCompleted }
    }
    
    var progressPercentage: Double {
        guard !tasks.isEmpty else { return 0.0 }
        return Double(completedTasks.count) / Double(tasks.count)
    }
    
    // MARK: - Task Management
    func addCard(type: CardType, title: String, content: String, isBothSides: Bool) {
        guard !title.isEmpty else { return }
        
        let newTask = ShortCardModel(
            title: title,
            description: content,
            isCompleted: false,
            cardType: type,
            isBothSides: isBothSides,
            moduleId: module.id
        )
        
        do {
            try cardRepository.saveCard(newTask)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                tasks.append(newTask)
            }
        } catch {
            print("Ошибка сохранения карточки: \(error)")
        }
    }
    
    func editCard(cardId: UUID, type: CardType, title: String, content: String, isBothSides: Bool) {
        guard !title.isEmpty, let index = tasks.firstIndex(where: { $0.id == cardId }) else { return }
        
        var updatedTask = tasks[index]
        updatedTask.title = title
        updatedTask.description = content
        updatedTask.cardType = type
        updatedTask.isBothSides = isBothSides
        
        do {
            try cardRepository.saveCard(updatedTask)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                tasks[index] = updatedTask
            }
        } catch {
            print("Ошибка обновления карточки: \(error)")
        }
    }
    
    func toggleTaskCompletion(_ task: ShortCardModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tasks[index].isCompleted.toggle()
            }
            
            // Сохраняем изменения в Core Data
            do {
                try cardRepository.saveCard(tasks[index])
            } catch {
                print("Ошибка обновления карточки: \(error)")
                // Откатываем изменения в случае ошибки
                tasks[index].isCompleted.toggle()
            }
        }
    }
    
    func deleteTask(_ task: ShortCardModel) {
        // Добавляем ID в список удаляемых для анимации
        deletingTaskIds.insert(task.id)
        
        // Запускаем анимацию уменьшения
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            // Анимация уменьшения будет обработана в View
        }
        
        // Удаляем из Core Data и массива с задержкой для анимации
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            do {
                try self.cardRepository.deleteCard(with: task.id)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    self.tasks.removeAll { $0.id == task.id }
                    self.deletingTaskIds.remove(task.id)
                }
            } catch {
                print("Ошибка удаления карточки: \(error)")
                // Убираем из списка удаляемых в случае ошибки
                self.deletingTaskIds.remove(task.id)
            }
        }
    }
    
    // MARK: - Study Management
    func startStudyingCards() {
        showingStudyCards = true
    }
    
    // MARK: - UI State Management
    func showAddCardType() {
        showingAddCardType = true
    }
    
    func showEditCard(_ card: ShortCardModel) {
        editingCard = card
        showingEditCardType = true
    }
    
    // MARK: - Private Methods
    private func loadTasks() {
        do {
            tasks = try cardRepository.fetchCards(for: module.id)
        } catch {
            print("Ошибка загрузки карточек: \(error)")
            tasks = []
        }
    }
    
    // MARK: - Public Methods
    func refreshTasks() {
        loadTasks()
    }
}

// MARK: - CardType Enum
enum CardType: String, CaseIterable {
    case short = "short"
    case regular = "regular"
    case test = "test"
    
    var displayName: String {
        switch self {
        case .short: return "Короткая карточка"
        case .regular: return "Карточка"
        case .test: return "Карточка-тест"
        }
    }
    
    var iconName: String {
        switch self {
        case .short: return "text.alignleft"
        case .regular: return "doc.text"
        case .test: return "checklist"
        }
    }
    
    var description: String {
        switch self {
        case .short: return "Краткая информация или определение"
        case .regular: return "Подробное объяснение с примерами"
        case .test: return "Вопрос с вариантами ответов"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .short:
            return LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.kiwi]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .regular:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.oceanBlue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .test:
            return LinearGradient(
                gradient: Gradient(colors: [Color.watermelonRed, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}


