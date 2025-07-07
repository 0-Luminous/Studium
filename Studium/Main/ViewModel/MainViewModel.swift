import SwiftUI
import Foundation
import CoreData

class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showingAddOptions = false
    @Published var items: [MainItem] = []
    @Published var showingAddModule = false
    @Published var showingAddFolder = false
    @Published var currentFolderId: UUID? = nil // Текущая папка (nil = корневая)
    @Published var navigationPath: [MainItem] = [] // Путь навигации
    @Published var selectedModule: MainItem? = nil // Выбранный модуль для показа
    @Published var showingModuleView = false // Показывать ли ModuleView
    
    // MARK: - CoreData Service
    private let coreDataService = CoreDataService()
    
    // MARK: - Initialization
    init() {
        loadItems()
    }
    
    // MARK: - Computed Properties
    
    /// Фильтрованные элементы для текущей папки
    var currentItems: [MainItem] {
        items.filter { $0.parentId == currentFolderId }
    }
    
    /// Текст breadcrumb для навигации
    var breadcrumbText: String {
        if navigationPath.count <= 1 {
            return "Studium"
        } else {
            let path = ["Studium"] + navigationPath.dropLast().map { $0.name }
            return path.joined(separator: " → ")
        }
    }
    
    // MARK: - Data Loading
    
    /// Загружает элементы из CoreData
    func loadItems() {
        items = coreDataService.fetchAllItemsFromDatabase()
    }
    
    /// Обновляет элементы для текущей папки
    func refreshCurrentItems() {
        items = coreDataService.fetchAllItemsFromDatabase()
    }
    
    // MARK: - Navigation Methods
    
    /// Обработка нажатия на элемент
    func handleItemTap(_ item: MainItem) {
        if item.type == .folder {
            navigateToFolder(item)
        } else {
            // Навигация к модулю
            selectedModule = item
            showingModuleView = true
        }
    }
    
    /// Навигация в папку
    func navigateToFolder(_ folder: MainItem) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            navigationPath.append(folder)
            currentFolderId = folder.id
        }
    }
    
    /// Возврат к предыдущей папке
    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            navigationPath.removeLast()
            currentFolderId = navigationPath.last?.id
        }
    }
    
    // MARK: - Item Management
    
    /// Добавление нового модуля
    func addModule(name: String, gradient: LinearGradient, description: String) {
        guard !name.isEmpty else { return }
        
        // Извлекаем цвета из градиента (упрощенная реализация)
        let (startColor, endColor) = extractColorsFromGradient(gradient)
        
        if let _ = coreDataService.createModule(
            name: name,
            gradientStartColor: startColor,
            gradientEndColor: endColor,
            parentId: currentFolderId
        ) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                refreshCurrentItems()
            }
        }
    }
    
    /// Добавление нового модуля с индексом градиента
    func addModule(name: String, gradientIndex: Int, description: String) {
        guard !name.isEmpty else { return }
        
        let (startColor, endColor) = getGradientColorsFromIndex(gradientIndex)
        
        if let _ = coreDataService.createModule(
            name: name,
            gradientStartColor: startColor,
            gradientEndColor: endColor,
            parentId: currentFolderId
        ) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                refreshCurrentItems()
            }
        }
    }
    
    /// Добавление новой папки
    func addFolder(name: String) {
        guard !name.isEmpty else { return }
        
        if let _ = coreDataService.createFolder(name: name, parentId: currentFolderId) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                refreshCurrentItems()
            }
        }
    }
    
    /// Удаление элемента
    func deleteItem(_ item: MainItem) {
        coreDataService.deleteItem(id: item.id, type: item.type)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            refreshCurrentItems()
        }
    }
    
    // MARK: - UI State Management
    
    /// Переключение меню добавления
    func toggleAddOptions() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showingAddOptions.toggle()
        }
    }
    
    /// Закрытие меню добавления
    func hideAddOptions() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showingAddOptions = false
        }
    }
    
    /// Показ экрана создания модуля
    func showAddModule() {
        hideAddOptions()
        showingAddModule = true
    }
    
    /// Показ экрана создания папки
    func showAddFolder() {
        hideAddOptions()
        showingAddFolder = true
    }
    
    // MARK: - Helper Methods
    
    /// Извлекает цвета из градиента для сохранения в CoreData
    private func extractColorsFromGradient(_ gradient: LinearGradient) -> (String, String) {
        // Маппинг предустановленных градиентов из AddModuleView
        let predefinedGradients: [(String, String)] = [
            ("aquaGreen", "limeGreen"),
            ("stormBlue", "jungleGreen"),
            ("green", "teal"),
            ("oceanBlue", "softTeal"),
            ("cyan", "blue"),
            ("blue", "purple"),
            ("red", "coral"),
            ("watermelonRed", "amber"),
            ("neonPink", "watermelonRed"),
            ("lilacGray", "cherryRed")
        ]
        
        // Для упрощения возвращаем случайную пару цветов из предустановленных
        // В реальном приложении здесь можно было бы анализировать переданный градиент
        let randomIndex = Int.random(in: 0..<predefinedGradients.count)
        return predefinedGradients[randomIndex]
    }
    
    /// Получает цвета градиента по индексу
    private func getGradientColorsFromIndex(_ index: Int) -> (String, String) {
        let predefinedGradients: [(String, String)] = [
            ("aquaGreen", "limeGreen"),
            ("stormBlue", "jungleGreen"),
            ("green", "teal"),
            ("oceanBlue", "softTeal"),
            ("cyan", "blue"),
            ("blue", "purple"),
            ("red", "coral"),
            ("watermelonRed", "amber"),
            ("neonPink", "watermelonRed"),
            ("lilacGray", "cherryRed")
        ]
        
        let validIndex = max(0, min(index, predefinedGradients.count - 1))
        return predefinedGradients[validIndex]
    }
}
