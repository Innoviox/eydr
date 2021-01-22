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
        ScrollView(.horizontal, showsIndicators: false) {
            loadData()
        }
    }
    
    func loadData() -> AnyView {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            let fetched = try viewContext.fetch(fetchRequest) as! [Item]

            return AnyView(HStack {
                ForEach(fetched, id: \.self) { item in
                    VStack {
                        Text("\(item.morning + item.afternoon)")
                        Text("\(item.timestamp!.get(.day))")
                            .padding(8)
                            .background(Color.blue)
                            .cornerRadius(8)
                        Text("\(item.steps)")
                    }
                }
            })
        } catch {
            print("Failed to fetch items: \(error)")
        }
        
        return AnyView(HStack { Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/) })
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
