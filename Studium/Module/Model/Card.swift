import Foundation
import CoreData

// MARK: - ShortCardModel

struct ShortCardModel: Identifiable, Hashable {
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

    // MARK: - Hashable Implementation

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ShortCardModel, rhs: ShortCardModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Card Extension
extension Card {
    
    /// Инициализирует Card из ShortCardModel
    convenience init(from moduleCard: ShortCardModel, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = moduleCard.id
        self.title = moduleCard.title
        self.content = moduleCard.description
        self.cardType = moduleCard.cardType.rawValue
        self.isCompleted = moduleCard.isCompleted
        self.isBothSides = moduleCard.isBothSides
        self.moduleId = moduleCard.moduleId
        self.createdAt = moduleCard.createdAt
    }
    
    /// Конвертирует Card в ShortCardModel
    func toShortCardModel() -> ShortCardModel {
        return ShortCardModel(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            description: self.content ?? "",
            isCompleted: self.isCompleted,
            cardType: CardType(rawValue: self.cardType ?? "regular") ?? .regular,
            isBothSides: self.isBothSides,
            moduleId: self.moduleId ?? UUID(),
            createdAt: self.createdAt ?? Date()
        )
    }
}

// MARK: - Card Repository
class CardRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataService.shared.context) {
        self.context = context
    }
    
    /// Сохраняет карточку в Core Data
    func saveCard(_ moduleCard: ShortCardModel) throws {
        // Проверяем, существует ли уже карточка с таким ID
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", moduleCard.id as CVarArg)
        
        let existingCards = try context.fetch(request)
        
        let card: Card
        if let existingCard = existingCards.first {
            // Обновляем существующую карточку
            card = existingCard
        } else {
            // Создаем новую карточку
            card = Card(context: context)
            card.id = moduleCard.id
        }
        
        // Обновляем данные
        card.title = moduleCard.title
        card.content = moduleCard.description
        card.cardType = moduleCard.cardType.rawValue
        card.isCompleted = moduleCard.isCompleted
        card.isBothSides = moduleCard.isBothSides
        card.moduleId = moduleCard.moduleId
        card.createdAt = moduleCard.createdAt
        
        try CoreDataService.shared.save()
    }
    
    /// Загружает все карточки для указанного модуля
    func fetchCards(for moduleId: UUID) throws -> [ShortCardModel] {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "moduleId == %@", moduleId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Card.createdAt, ascending: true)]
        
        let cards = try context.fetch(request)
        return cards.map { $0.toShortCardModel() }
    }
    
    /// Удаляет карточку по ID
    func deleteCard(with id: UUID) throws {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let cards = try context.fetch(request)
        for card in cards {
            context.delete(card)
        }
        
        try CoreDataService.shared.save()
    }
    
    /// Удаляет все карточки для указанного модуля
    func deleteAllCards(for moduleId: UUID) throws {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "moduleId == %@", moduleId as CVarArg)
        
        let cards = try context.fetch(request)
        for card in cards {
            context.delete(card)
        }
        
        try CoreDataService.shared.save()
    }
} 