//
//  QuitSmokingApp.swift
//  QuitSmoking
//
//  Created by iwamoto rinka on 2025/03/02.
//

import SwiftUI

@main
struct QuitSmokingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
