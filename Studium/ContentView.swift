//
//  ContentView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI
import CoreData

// Модель для элементов
struct StudiumItem: Identifiable {
    let id = UUID()
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
}

struct ContentView: View {
    @State private var showingAddOptions = false
    @State private var items: [StudiumItem] = []
    @State private var showingNameInput = false
    @State private var newItemName = ""
    @State private var newItemType: StudiumItem.ItemType = .module
    @State private var currentFolderId: UUID? = nil // Текущая папка (nil = корневая)
    @State private var navigationPath: [StudiumItem] = [] // Путь навигации
    
    // Вычисляемые свойства для адаптивной сетки
    private var gridColumns: [GridItem] {
        let spacing: CGFloat = 16
        let minItemWidth: CGFloat = 150
        
        return [
            GridItem(.adaptive(minimum: minItemWidth, maximum: 200), spacing: spacing)
        ]
    }
    
    // Фильтрованные элементы для текущей папки
    private var currentItems: [StudiumItem] {
        items.filter { $0.parentId == currentFolderId }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Заголовок с навигацией
                HStack {
                    if !navigationPath.isEmpty {
                        Button(action: {
                            navigateBack()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(navigationPath.last?.name ?? "Studium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if !navigationPath.isEmpty {
                            Text(breadcrumbText)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Сетка элементов
                if currentItems.isEmpty {
                    // Пустое состояние
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: currentFolderId == nil ? "square.stack.3d.up" : "folder")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .opacity(0.6)
                        
                        VStack(spacing: 8) {
                            Text(currentFolderId == nil ? "Добро пожаловать!" : "Пустая папка")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(currentFolderId == nil ? "Создайте свой первый модуль или папку" : "Добавьте модули или папки")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 20) {
                            ForEach(currentItems) { item in
                                StudiumItemView(item: item) {
                                    // Действие при нажатии
                                    handleItemTap(item)
                                } onDelete: {
                                    // Действие при удалении
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        deleteItem(item)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100) // Отступ для кнопки
                    }
                }
                
                Spacer()
                
                // Кнопка добавления
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showingAddOptions.toggle()
                        }
                    }) {
                        Image(systemName: showingAddOptions ? "xmark" : "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(showingAddOptions ? Color.red : Color.accentColor)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(red: 0.098, green: 0.098, blue: 0.098))
            
            // Меню добавления
            if showingAddOptions {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            // Кнопка модуля
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showingAddOptions = false
                                }
                                newItemType = .module
                                showingNameInput = true
                            }) {
                                HStack {
                                    Image(systemName: "tray.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .frame(width: 24)
                                    Text("Модуль")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                            }
                            
                            // Кнопка папки
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showingAddOptions = false
                                }
                                newItemType = .folder
                                showingNameInput = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.rectangle.on.folder.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .frame(width: 24)
                                    Text("Папка")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                            }
                        }
                        .frame(width: 140)
                        .padding(.trailing, 20)
                        .padding(.bottom, 90)
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .offset(x: 20, y: 20)),
                    removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .offset(x: 20, y: 20))
                ))
            }
        }
        .onTapGesture {
            if showingAddOptions {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showingAddOptions = false
                }
            }
        }
        .alert("Добавить \(newItemType.displayName)", isPresented: $showingNameInput) {
            TextField("Название", text: $newItemName)
            Button("Отмена", role: .cancel) {
                newItemName = ""
            }
            Button("Добавить") {
                addItem()
            }
        } message: {
            Text("Введите название для нового \(newItemType.displayName)")
        }
    }
    
    // Функции навигации
    private func handleItemTap(_ item: StudiumItem) {
        if item.type == .folder {
            navigateToFolder(item)
        } else {
            print("Tapped on module: \(item.name)")
        }
    }
    
    private func navigateToFolder(_ folder: StudiumItem) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            navigationPath.append(folder)
            currentFolderId = folder.id
        }
    }
    
    private func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            navigationPath.removeLast()
            currentFolderId = navigationPath.last?.id
        }
    }
    
    private var breadcrumbText: String {
        if navigationPath.count <= 1 {
            return "Studium"
        } else {
            let path = ["Studium"] + navigationPath.dropLast().map { $0.name }
            return path.joined(separator: " → ")
        }
    }
    
    private func deleteItem(_ item: StudiumItem) {
        // Если удаляем папку, удаляем все её содержимое
        if item.type == .folder {
            deleteItemsInFolder(item.id)
        }
        items.removeAll { $0.id == item.id }
    }
    
    private func deleteItemsInFolder(_ folderId: UUID) {
        let itemsToDelete = items.filter { $0.parentId == folderId }
        for item in itemsToDelete {
            if item.type == .folder {
                deleteItemsInFolder(item.id)
            }
            items.removeAll { $0.id == item.id }
        }
    }
    
    private func addItem() {
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
        
        let newItem = StudiumItem(
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
}

// Отдельный компонент для элемента сетки
struct StudiumItemView: View {
    let item: StudiumItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Квадратная иконка
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(item.gradient)
                    .frame(height: 120)
                    .shadow(
                        color: .black.opacity(0.25),
                        radius: isPressed ? 4 : 8,
                        x: 0,
                        y: isPressed ? 2 : 6
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                VStack(spacing: 8) {
                    Image(systemName: item.type.iconName)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Небольшая дата создания
                    Text(item.createdAt, style: .date)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Название
            Text(item.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Показать меню удаления
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onDelete()
            }
        }
        .onPressGesture(
            onPress: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
            },
            onRelease: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        )
    }
}

// Расширение для обработки нажатий
extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
