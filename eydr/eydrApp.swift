//
//  eydrApp.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI

@main
struct eydrApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
