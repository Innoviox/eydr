//
//  HistoryView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import SwiftUI
import CoreData

func makeBarHeights(_ items: [Item], getter: (Item) -> CGFloat) -> [CGFloat] {
    let heights = items.map(getter)
    
    let min = heights.min()!, max = heights.max()!
    
    
    return heights.map { $0 / (max == 0 ? 1 : max) * 200 }
}

struct BarView: View{

    var value: CGFloat
    var cornerRadius: CGFloat
    
    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: 200).foregroundColor(.white)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 30, height: value).foregroundColor(.green)
                
            }.padding(.bottom, 8)
        }
        
    }
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
            
            let topHeights = makeBarHeights(fetched) { CGFloat($0.morning + $0.afternoon) }
            let botHeights = makeBarHeights(fetched) { CGFloat($0.steps) }
            
            print(topHeights, botHeights)

            return AnyView(HStack {
                ForEach(0...(fetched.count - 1), id: \.self) { i in
                    let item = fetched[i]
                    VStack {
                        BarView(value: topHeights[i], cornerRadius: 1)
                        Text("\(item.timestamp!.get(.day))")
                            .padding(8)
                            .background(Color.blue)
                            .cornerRadius(8)
                        BarView(value: botHeights[i], cornerRadius: 1)
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
