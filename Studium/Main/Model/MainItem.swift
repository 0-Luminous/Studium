import SwiftUI
import CoreData

struct MainItem: Identifiable {
    let id: UUID
    let name: String
    let type: ItemType
    let gradient: LinearGradient
    let createdAt: Date
    let parentId: UUID? // Добавляем поддержку родительской папки

    enum ItemType {
        case module
        case folder

        var iconName: String {
            switch self {
            case .module: return "tray.fill"
            case .folder: return "folder.fill"
            }
        }

        var displayName: String {
            switch self {
            case .module: return "модуль"
            case .folder: return "папку"
            }
        }
    }
    
    // MARK: - Initialization
    
    /// Стандартный инициализатор для создания MainItem напрямую
    init(id: UUID = UUID(), name: String, type: ItemType, gradient: LinearGradient, createdAt: Date = Date(), parentId: UUID? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.gradient = gradient
        self.createdAt = createdAt
        self.parentId = parentId
    }
    
    // MARK: - CoreData Integration
    
    /// Инициализатор из CoreData сущности Folder
    init(from folder: Folder) {
        self.id = folder.value(forKey: "id") as? UUID ?? UUID()
        self.name = folder.name ?? ""
        self.type = .folder
        self.gradient = LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.red]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        self.createdAt = folder.createdAt ?? Date()
        self.parentId = folder.value(forKey: "parentId") as? UUID
    }
    
    /// Инициализатор из CoreData сущности Module
    init(from module: Module) {
        self.id = module.value(forKey: "id") as? UUID ?? UUID()
        self.name = module.name ?? ""
        self.type = .module
        self.gradient = Self.gradientFromColors(
            start: module.gradientStartColor,
            end: module.gradientEndColor
        )
        self.createdAt = module.createdAt ?? Date()
        self.parentId = module.value(forKey: "parentId") as? UUID
    }
    
    /// Создает градиент из строковых значений цветов
    private static func gradientFromColors(start: String?, end: String?) -> LinearGradient {
        let startColor = colorFromString(start) ?? Color.blue
        let endColor = colorFromString(end) ?? Color.purple
        
        return LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Преобразует строку в Color
    private static func colorFromString(_ colorString: String?) -> Color? {
        guard let colorString = colorString else { return nil }
        
        switch colorString {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        case "cyan": return .cyan
        case "teal": return .teal
        case "aquaGreen": return Color("aquaGreen")
        case "limeGreen": return Color("limeGreen")
        case "stormBlue": return Color("stormBlue")
        case "jungleGreen": return Color("jungleGreen")
        case "oceanBlue": return Color("oceanBlue")
        case "softTeal": return Color("softTeal")
        case "coral": return Color("coral")
        case "watermelonRed": return Color("watermelonRed")
        case "amber": return Color("amber")
        default: return nil
        }
    }
    
    /// Получает строковое представление цвета для сохранения в CoreData
    static func stringFromColor(_ color: Color) -> String {
        // Упрощенная реализация - возвращаем дефолтные значения
        // В реальном приложении нужно было бы сравнивать цвета или передавать индекс
        return "blue" // Дефолтное значение
    }
    
    /// Извлекает цвета из градиента для сохранения в CoreData
    func getGradientColors() -> (String, String) {
        // Для упрощения возвращаем предустановленные значения
        // В реальном приложении здесь можно было бы извлекать цвета из градиента
        switch type {
        case .folder:
            return ("orange", "red")
        case .module:
            return ("blue", "purple") // Дефолтное значение, можно расширить логику
        }
    }
}