//
//  StudiumApp.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

@main
struct StudiumApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
