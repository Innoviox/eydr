//
//  eydr2App.swift
//  eydr2
//
//  Created by Simon Chervenak on 8/13/21.
//

import SwiftUI

@main
struct eydr2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
