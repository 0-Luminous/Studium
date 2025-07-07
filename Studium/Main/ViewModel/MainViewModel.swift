import SwiftUI
import Foundation

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
        
        let newItem = MainItem(
            name: name,
            type: .module,
            gradient: gradient,
            createdAt: Date(),
            parentId: currentFolderId
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            items.append(newItem)
        }
    }
    
    /// Добавление новой папки
    func addFolder(name: String) {
        guard !name.isEmpty else { return }
        
        let gradient = LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.red]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        let newItem = MainItem(
            name: name,
            type: .folder,
            gradient: gradient,
            createdAt: Date(),
            parentId: currentFolderId
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            items.append(newItem)
        }
    }
    
    /// Удаление элемента
    func deleteItem(_ item: MainItem) {
        // Если удаляем папку, удаляем все её содержимое
        if item.type == .folder {
            deleteItemsInFolder(item.id)
        }
        items.removeAll { $0.id == item.id }
    }
    
    /// Рекурсивное удаление элементов в папке
    private func deleteItemsInFolder(_ folderId: UUID) {
        let itemsToDelete = items.filter { $0.parentId == folderId }
        for item in itemsToDelete {
            if item.type == .folder {
                deleteItemsInFolder(item.id)
            }
            items.removeAll { $0.id == item.id }
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
}
