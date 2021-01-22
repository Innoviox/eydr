//
//  ContentView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import CoreData
import HealthKit
import MapKit

let FONT: Font = .system(size: 60)

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var locationManager = LocationManager()
    
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
            
            makeMap()
            
            makeSteps()
        }
    }
    
    func makeBox(i: Int) -> some View {
        return HStack {
                    Button(action: {
                        if counts[i] > 0 {
                            counts[i] -= 1
                            is0[i] = counts[i] == 0
                            updateToday()
                        }
                    }, label: {
                        Text("-").font(FONT)
                    }).disabled(is0[i])
                    Text("\(counts[i])").font(FONT)
                    Button(action: {
                        counts[i] += 1
                        is0[i] = counts[i] == 0
                        updateToday()
                    }, label: {
                        Text("+").font(FONT)
                    })
               }
               .padding()
               .border(Color.black)
    }
    
    func makeMap() -> some View {
        return Map(coordinateRegion: $locationManager.region)
            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
    }
    
    func makeSteps() -> some View {
        retrieveStepCount()
        
        return HStack {
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
        .border(Color.black)
    }
    
    func retrieveStepCount() {
        let date = Date()
        let newDate = Calendar(identifier: Calendar.Identifier.gregorian).startOfDay(for: date)

        let query = HKStatisticsCollectionQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantitySamplePredicate: HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate), options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { query, results, error in
            if error != nil || results == nil { return }

            results!.enumerateStatistics(from: newDate, to: date) { s, _ in
                self.steps = Int(s.sumQuantity()!.doubleValue(for: HKUnit.count()))
                
                if let item = findToday() {
                    self.counts = [Int(item.morning), Int(item.afternoon)]
                    self.is0[0] = self.counts[0] == 0
                    self.is0[1] = self.counts[1] == 0
                }
                
                updateToday()
            }
        }

        healthStore.execute(query)
    }
    
    func findToday() -> Item? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            let fetched = try viewContext.fetch(fetchRequest) as! [Item]
            
            let cdc = Date().get(.day, .month, .year)
            for item in fetched {
                let idc = item.timestamp!.get(.day, .month, .year)
                if cdc.day == idc.day && cdc.month == idc.month && cdc.year == idc.year {
                    return item
                }
            }
        } catch {
            print("Failed to fetch items: \(error)")
        }
        
        return nil
    }
    
    func updateToday() {
        if let item = findToday() {
            updateItem(item)
        } else {
            makeToday()
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func makeToday() {
        let newItem = Item(context: viewContext)
        newItem.timestamp = Date()
        updateItem(newItem)
    }
    
    func updateItem(_ i: Item) {
        i.morning = Int16(counts[0])
        i.afternoon = Int16(counts[1])
        i.steps = Int16(steps)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
