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
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
