import SwiftUI
import Foundation

class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showingAddOptions = false
    @Published var items: [MainItem] = []
    @Published var showingNameInput = false
    @Published var newItemName = ""
    @Published var newItemType: MainItem.ItemType = .module
    @Published var currentFolderId: UUID? = nil // Текущая папка (nil = корневая)
    @Published var navigationPath: [MainItem] = [] // Путь навигации
    
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
            print("Tapped on module: \(item.name)")
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
    
    /// Добавление нового элемента
    func addItem() {
        guard !newItemName.isEmpty else { return }
        
        let gradient = newItemType == .module ?
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        
        let newItem = MainItem(
            name: newItemName,
            type: newItemType,
            gradient: gradient,
            createdAt: Date(),
            parentId: currentFolderId // Добавляем в текущую папку
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            items.append(newItem)
        }
        
        newItemName = ""
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
    
    /// Подготовка к добавлению модуля
    func prepareAddModule() {
        hideAddOptions()
        newItemType = .module
        showingNameInput = true
    }
    
    /// Подготовка к добавлению папки
    func prepareAddFolder() {
        hideAddOptions()
        newItemType = .folder
        showingNameInput = true
    }
    
    /// Отмена добавления элемента
    func cancelAddItem() {
        newItemName = ""
    }
}
