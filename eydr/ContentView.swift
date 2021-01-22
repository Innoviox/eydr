//
//  ContentView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import CoreData
import HealthKit

let FONT: Font = .system(size: 60)

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var counts = [0, 0]
    @State var is0 = [true, true]
    @State var steps = 0

    var body: some View {
        VStack {
            HStack {
                makeBox(i: 0)
                makeBox(i: 1)
            }
            .frame(maxWidth: .infinity)
            
            makeSteps()
        }
    }
    
    func makeBox(i: Int) -> AnyView {
        return AnyView(HStack {
                            Button(action: {
                                if counts[i] > 0 {
                                    counts[i] -= 1
                                    is0[i] = counts[i] == 0
                                }
                            }, label: {
                                Text("-").font(FONT)
                            }).disabled(is0[i])
                            Text("\(counts[i])").font(FONT)
                            Button(action: {
                                counts[i] += 1
                                is0[i] = counts[i] == 0
                            }, label: {
                                Text("+").font(FONT)
                            })
                       }
                       .padding()
                       .border(Color.black)
        .frame(maxWidth: .infinity))
    }
    
    func makeSteps() -> AnyView {
        retrieveStepCount()
        
        return AnyView(HStack {
            Label {
                Text("\(steps)")
                    .font(.title)
            } icon: {
                Image("shoes")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .border(Color.black))
    }
    
    func retrieveStepCount() {
        let stepsCount = HKQuantityType.quantityType(forIdentifier: .stepCount)

        let date = Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)

        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents:interval)

        query.initialResultsHandler = { query, results, error in
            if error != nil { return }

            if let r = results {
                r.enumerateStatistics(from: newDate, to: date) { statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        self.steps = Int(quantity.doubleValue(for: HKUnit.count()))
                    }
                }
            }
        }

        healthStore.execute(query)
   }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
