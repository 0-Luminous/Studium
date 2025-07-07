import CoreData
import SwiftUI

class CoreDataService: ObservableObject {
    let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = persistentContainer
    }
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Folder Operations
    
    /// Создает новую папку в CoreData
    func createFolder(name: String, parentId: UUID? = nil) -> Folder? {
        let context = viewContext
        
        let folder = Folder(context: context)
        folder.setValue(UUID(), forKey: "id")
        folder.name = name
        folder.createdAt = Date()
        folder.setValue(parentId, forKey: "parentId")
        
        do {
            try context.save()
            return folder
        } catch {
            print("Error creating folder: \(error)")
            return nil
        }
    }
    
    /// Получает все папки из CoreData
    func fetchFolders(parentId: UUID? = nil) -> [Folder] {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        if let parentId = parentId {
            request.predicate = NSPredicate(format: "parentId == %@", parentId as CVarArg)
        } else {
            request.predicate = NSPredicate(format: "parentId == nil")
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching folders: \(error)")
            return []
        }
    }
    
    /// Удаляет папку и все её содержимое
    func deleteFolder(_ folder: Folder) {
        let context = viewContext
        
        // Удаляем все дочерние элементы
        if let folderId = folder.value(forKey: "id") as? UUID {
            deleteItemsInFolder(folderId)
        }
        
        context.delete(folder)
        
        do {
            try context.save()
        } catch {
            print("Error deleting folder: \(error)")
        }
    }
    
    // MARK: - Module Operations
    
    /// Создает новый модуль в CoreData
    func createModule(name: String, gradientStartColor: String, gradientEndColor: String, parentId: UUID? = nil) -> Module? {
        let context = viewContext
        
        let module = Module(context: context)
        module.setValue(UUID(), forKey: "id")
        module.name = name
        module.gradientStartColor = gradientStartColor
        module.gradientEndColor = gradientEndColor
        module.createdAt = Date()
        module.setValue(parentId, forKey: "parentId")
        
        do {
            try context.save()
            return module
        } catch {
            print("Error creating module: \(error)")
            return nil
        }
    }
    
    /// Получает все модули из CoreData
    func fetchModules(parentId: UUID? = nil) -> [Module] {
        let request: NSFetchRequest<Module> = Module.fetchRequest()
        
        if let parentId = parentId {
            request.predicate = NSPredicate(format: "parentId == %@", parentId as CVarArg)
        } else {
            request.predicate = NSPredicate(format: "parentId == nil")
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching modules: \(error)")
            return []
        }
    }
    
    /// Удаляет модуль
    func deleteModule(_ module: Module) {
        let context = viewContext
        context.delete(module)
        
        do {
            try context.save()
        } catch {
            print("Error deleting module: \(error)")
        }
    }
    
    // MARK: - Combined Operations
    
    /// Получает все элементы (папки и модули) для указанного родителя
    func fetchAllItems(parentId: UUID? = nil) -> [MainItem] {
        let folders = fetchFolders(parentId: parentId)
        let modules = fetchModules(parentId: parentId)
        
        var items: [MainItem] = []
        
        // Преобразуем папки в MainItem
        for folder in folders {
            items.append(MainItem(from: folder))
        }
        
        // Преобразуем модули в MainItem
        for module in modules {
            items.append(MainItem(from: module))
        }
        
        // Сортируем по дате создания (новые сначала)
        return items.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Получает все элементы из CoreData (без фильтрации по parentId)
    func fetchAllItemsFromDatabase() -> [MainItem] {
        // Создаем запросы без предикатов для получения всех элементов
        let folderRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        folderRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let moduleRequest: NSFetchRequest<Module> = Module.fetchRequest()
        moduleRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        var items: [MainItem] = []
        
        do {
            // Получаем все папки
            let folders = try viewContext.fetch(folderRequest)
            for folder in folders {
                items.append(MainItem(from: folder))
            }
            
            // Получаем все модули
            let modules = try viewContext.fetch(moduleRequest)
            for module in modules {
                items.append(MainItem(from: module))
            }
        } catch {
            print("Error fetching all items: \(error)")
        }
        
        // Сортируем по дате создания (новые сначала)
        return items.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Удаляет элемент по ID и типу
    func deleteItem(id: UUID, type: MainItem.ItemType) {
        let context = viewContext
        
        switch type {
        case .folder:
            let request: NSFetchRequest<Folder> = Folder.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let folders = try context.fetch(request)
                if let folder = folders.first {
                    deleteFolder(folder)
                }
            } catch {
                print("Error finding folder to delete: \(error)")
            }
            
        case .module:
            let request: NSFetchRequest<Module> = Module.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let modules = try context.fetch(request)
                if let module = modules.first {
                    deleteModule(module)
                }
            } catch {
                print("Error finding module to delete: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Рекурсивно удаляет все элементы в папке
    private func deleteItemsInFolder(_ folderId: UUID) {
        // Удаляем дочерние папки
        let childFolders = fetchFolders(parentId: folderId)
        for folder in childFolders {
            deleteFolder(folder)
        }
        
        // Удаляем дочерние модули
        let childModules = fetchModules(parentId: folderId)
        for module in childModules {
            deleteModule(module)
        }
    }
} 