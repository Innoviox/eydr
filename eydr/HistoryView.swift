//
//  HistoryView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import CoreData

func makeBarHeights(_ items: [Item], getter: (Item) -> Int) -> [Int] {
    let heights = items.map(getter)
    
    let min = heights.min()!, max = heights.max()!
    
    
    return heights.map { ($0 - min) / (max - min) }
}

func Bar(_ height: Int) -> some View {

}

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
            
            let topHeights = makeBarHeights(fetched) { Int($0.morning + $0.afternoon) }
            let botHeights = makeBarHeights(fetched) { Int($0.steps) }

            return AnyView(HStack {
                ForEach(1...fetched.count, id: \.self) { i in
                    let item = fetched[i]
                    VStack {
                        Bar(topHeights[i])
                        Text("\(item.timestamp!.get(.day))")
                            .padding(8)
                            .background(Color.blue)
                            .cornerRadius(8)
                        Bar(botHeights[i])
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
