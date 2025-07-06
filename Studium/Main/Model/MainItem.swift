import SwiftUI

struct MainItem: Identifiable {
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