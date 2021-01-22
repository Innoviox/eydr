//
//  eydrApp.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import HealthKit

let healthStore = HKHealthStore()

@main
struct eydrApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    let allTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])

                    healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                        if !success {
                            // Handle the error here.
                        }
                    }}
        }
    }
}
