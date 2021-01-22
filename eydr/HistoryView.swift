//
//  HistoryView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        CalendarView(interval: calendar.dateInterval(of: .year, for: Date())!) { date in
            Text("30")
                .hidden()
                .padding(8)
                .background(Color.blue)
                .clipShape(Circle())
                .padding(.vertical, 4)
                .overlay(
                    Text(String(self.calendar.component(.day, from: date)))
                )
        }
    }
    
    func loadText() -> some View {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            let fetched = try viewContext.fetch(fetchRequest) as! [Item]

            for item in fetched {
                print("ITEM", item.timestamp, item.morning, item.afternoon, item.steps)
            }
        } catch {
            print("Failed to fetch items: \(error)")
        }
        
        return Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
