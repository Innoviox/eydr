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
            ContentView(calendar: Calendar(identifier: .gregorian), colors: persistenceController.container.viewContext.colorMatrix())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
