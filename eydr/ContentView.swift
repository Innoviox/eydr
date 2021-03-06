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
let MONO: Font = .system(size: 14, design: .monospaced)

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var locationManager = LocationManager()

    @State var counts = [0, 0]
    @State var is0 = [true, true]
    @State var steps = 0
    @State var runStr = ["play", "stop"]

    var body: some View {
        VStack {
            HStack {
                makeBox(i: 0)
                makeBox(i: 1)
            }
                .frame(maxWidth: .infinity)

            makeMap()

            HStack {
                Button(action: start, label: {
                    Image(systemName: runStr[0])
                        .font(FONT)
                        .foregroundColor(.green)
                })
                Button(action: pause, label: {
                    Image(systemName: runStr[1])
                        .font(FONT)
                        .foregroundColor(.red)
                })
            }

            makeSteps()
        }
    }

    func makeBox(i: Int) -> some View {
        return HStack {
            Button(action: {
                if counts[i] > 0 {
                    counts[i] -= 1
                    is0[i] = counts[i] == 0
                    viewContext.updateToday(counts: counts, steps: steps, manager: locationManager)
                }
            }, label: {
                Text("-").font(FONT)
            }).disabled(is0[i])
            Text("\(counts[i])").font(FONT)
            Button(action: {
                counts[i] += 1
                is0[i] = counts[i] == 0
                viewContext.updateToday(counts: counts, steps: steps, manager: locationManager)
            }, label: {
                Text("+").font(FONT)
            })
        }
            .padding()
            .border(Color.black)
    }

    func makeMap() -> some View {
        return MapView(route: $locationManager.polyline, locationManager: locationManager)
            .border(Color.black)
            .overlay(VStack {
                Text(locationManager.infoString).font(MONO)
                }
                .padding()
                .border(Color.black),
            alignment: .topLeading)
    }

    func makeSteps() -> some View {
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
            .onAppear(perform: retrieveStepCount)
    }

    func retrieveStepCount() {
        let date = Date()
        let newDate = Calendar(identifier: Calendar.Identifier.gregorian).startOfDay(for: date)

        let query = HKStatisticsCollectionQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantitySamplePredicate: HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate), options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { query, results, error in
            if error != nil || results == nil { return }

            results!.enumerateStatistics(from: newDate, to: date) { s, _ in
                self.steps = Int(s.sumQuantity()!.doubleValue(for: HKUnit.count()))

                if let item = viewContext.findToday() {
                    self.counts = [Int(item.morning), Int(item.afternoon)]
                    self.is0[0] = self.counts[0] == 0
                    self.is0[1] = self.counts[1] == 0
                    self.locationManager.update(item)
                    self.locationManager.setContext(viewContext)
                }

                viewContext.updateToday(counts: counts, steps: steps, manager: locationManager)
            }
        }

        healthStore.execute(query)
    }

    func start() {
        locationManager.lastTime = Date()
        locationManager.running = 2
        runStr = ["play.fill", "pause"]
    }

    func pause() {
        if runStr[1].starts(with: "pause") {
            locationManager.running = 1
            runStr = ["play", "stop.fill"]
        } else {
            locationManager.running = 0
            runStr = ["play.fill", "pause"]
            viewContext.updateToday(counts: counts, steps: steps, manager: locationManager)
        }
    }
}

extension ContentView {
    func populate() {
        var date = Date()
        for i in 0..<100 {
            date = date.addingTimeInterval(TimeInterval(-86400))

            let n = Item(context: viewContext)
            n.timestamp = date
            n.morning = Int16.random(in: 1..<5)
            n.afternoon = Int16.random(in: 1..<5)
            n.steps = Int16.random(in: 1..<15000)
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
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

extension NSManagedObjectContext {
    func findToday() -> Item? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            let fetched = try fetch(fetchRequest) as! [Item]

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

    func updateToday(counts: [Int], steps: Int, manager: LocationManager?) {
        if let item = findToday() {
            updateItem(item, counts, steps, manager)
            print("UPDATING4", findToday()!.length)
        } else {
            makeToday(counts: counts, steps: steps, manager: manager)
        }

        do {
            try save()
            print("UPDATING3 success")
        } catch {
            let nsError = error as NSError
            print("UPDATING5 Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func makeToday(counts: [Int], steps: Int, manager: LocationManager?) {
        let newItem = Item(context: self)
        newItem.timestamp = Date()
        newItem.running = -1
        updateItem(newItem, counts, steps, manager)
    }

    func updateItem(_ i: Item, _ counts: [Int], _ steps: Int, _ manager: LocationManager?) {
        if counts.count > 0 {
            i.morning = Int16(counts[0])
            i.afternoon = Int16(counts[1])
        }
        
        if steps != -1 {
            i.steps = Int16(steps)
        }

        if let locationManager = manager {
            i.length = locationManager.length
            i.time = locationManager.time

            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: Route(locationManager.route), requiringSecureCoding: false)
                i.route = data as NSObject
            } catch {
                print("UPDATING6 failed to save route")
            }

            print("UPDATING2", locationManager.length, locationManager.time)
            print()
        }
    }
}
