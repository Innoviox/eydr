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
    
    @State var counts = [0, 0]
    @State var is0 = [true, true]
    @State var steps = 0
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        VStack {
            HStack {
                makeBox(i: 0)
                makeBox(i: 1)
            }
            .frame(maxWidth: .infinity)
            
            Map(coordinateRegion: $region)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
            
            makeSteps()
        }
    }
    
    func makeBox(i: Int) -> some View {
        return HStack {
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
        let date = Date()
        let newDate = Calendar(identifier: Calendar.Identifier.gregorian).startOfDay(for: date)

        let query = HKStatisticsCollectionQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantitySamplePredicate: HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate), options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { query, results, error in
            if error != nil || results == nil { return }

            results!.enumerateStatistics(from: newDate, to: date) { s, _ in self.steps = Int(s.sumQuantity()!.doubleValue(for: HKUnit.count())) }
        }

        healthStore.execute(query)
   }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
