import SwiftUI
import Foundation

class ModuleViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tasks: [ModuleShortCard] = [] // Задачи модуля
    @Published var showingAddCardType = false // Убираем showingAddOptions
    @Published var showingStudyCards = false // Для отображения режима изучения
    
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
    var completedTasks: [ModuleShortCard] {
        tasks.filter { $0.isCompleted }
    }
    
    var progressPercentage: Double {
        guard !tasks.isEmpty else { return 0.0 }
        return Double(completedTasks.count) / Double(tasks.count)
    }
    
    // MARK: - Task Management
    func addCard(type: CardType, title: String, content: String, isBothSides: Bool) {
        guard !title.isEmpty else { return }
        
        let newTask = ModuleShortCard(
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
    
    func toggleTaskCompletion(_ task: ModuleShortCard) {
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
    
    func deleteTask(_ task: ModuleShortCard) {
        do {
            try cardRepository.deleteCard(with: task.id)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                tasks.removeAll { $0.id == task.id }
            }
        } catch {
            print("Ошибка удаления карточки: \(error)")
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
                gradient: Gradient(colors: [Color.green, Color.teal]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .regular:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .test:
            return LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - ModuleShortCard Model
struct ModuleShortCard: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool = false
    var cardType: CardType = .regular
    var isBothSides: Bool = true
    let moduleId: UUID
    let createdAt: Date
    
    init(id: UUID = UUID(), title: String, description: String, isCompleted: Bool = false, cardType: CardType = .regular, isBothSides: Bool = true, moduleId: UUID, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.cardType = cardType
        self.isBothSides = isBothSides
        self.moduleId = moduleId
        self.createdAt = createdAt
    }
}
